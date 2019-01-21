#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using Xml;
using haxe.macro.MacroStringTools;

class TemplateBuilder {

  static final placeholderStart:String = '{{__scout__';
  static final placeholderRe = ~/{{__scout__(\d)*}}/ig;
  static final placeholderReSplitter = ~/{{__scout__\d*}}/ig;
  static var id:Int = 0;

  public static function parse(tpl:ExprOf<String>) {
    return switch (tpl.expr) {
      case EConst(CString(s)):
        var expr = s.formatString(tpl.pos);
        var values:Array<Expr> = [];
        var str = firstPass(expr, values);
        secondPass(str, values);
      default:
        // macro @:pos(tpl.pos) new scout.html.TemplateResult(${tpl}, []);
        tpl;
    }
  }

  static function firstPass(e:Expr, values:Array<Expr>):String {
    var parts:String = '';
    switch(e.expr) {
      case EBinop(OpAdd, e1, e2): 
        parts += firstPass(e1, values) + firstPass(e2, values);
      case EConst(CString(s)): 
        parts += s;
      default:
        values.push(e);
        var key = placeholderStart + values.indexOf(e) + '}}';
        parts += key;
    }
    return parts;
  }

  static function getId() {
    return id += 1;
  }

  static function secondPass(str:String, values:Array<Expr>) {
    // var pack = Context.getLocalClass().get().pack;
    var root = Xml.parse(str);
    var exprs:Array<Expr> = [];
    for (node in root) switch (node.nodeType) {
      case Element: exprs.push(macro __e.appendChild(${createElementFromXml(node)}));
      case PCData: exprs.push(handleDataNode(node));
      default:
    }
    var name = 'TemplateFactory_' + getId();
    Context.defineModule('scout.html.${name}', [ macro class $name implements scout.html.TemplateFactory {

      public final id:String = $v{name};
      // public final debug:String = $v{str};

      public function new() {}

      public function get() {
        var __parts:Array<Null<scout.html.Part>> = [];
        var __e = js.Browser.document.createDocumentFragment();
        $b{exprs};
        var __t = new scout.html.Template(id, cast __e, __parts);
        return __t;
      }

    } ]);
    return macro new scout.html.TemplateResult(new scout.html.$name(), [ $a{values} ]);
  }

  static function createElementFromXml(node:Xml) {
    var name = node.nodeName;
    var body:Array<Expr> = [];
    var attrs = [ for (n in node.attributes()) n ];
    attrs.sort((a, b) -> {
      var aVal = node.get(a);
      var bVal = node.get(b);
      if (!placeholderRe.match(aVal) && !placeholderRe.match(bVal)) {
        return 0;
      } else if (placeholderRe.match(aVal) && !placeholderRe.match(bVal)) {
        return 1;
      } else if (!placeholderRe.match(aVal) && placeholderRe.match(bVal)) {
        return -1;
      } else {
        placeholderRe.match(aVal);
        var aIndex = Std.parseInt(placeholderRe.matched(1));
        placeholderRe.match(bVal);
        var bIndex = Std.parseInt(placeholderRe.matched(1));
        return aIndex > bIndex ? 1 : -1;
      }
    });

    for (attrName in attrs) {
      var attrValue:String = node.get(attrName);
      if (attrName.startsWith('on:')) {
        var event = attrName.substr(3);
        if (!placeholderRe.match(attrValue)) {
          Context.error('Only functions are allowed for `on:$event` attributes', Context.currentPos());
        }
        body.push(macro {
          var __ev = new scout.html.part.EventPart(
            __e,
            $v{event}
          );
          __parts.push(__ev);
        });
      } else if (attrName.startsWith('is:')) {
        var name = attrName.substr(3);
        if (!placeholderRe.match(attrValue)) {
          body.push(macro {
            var __truthy:Bool = !!$v{attrValue};
            if (__truthy) __e.setAttribute($v{name}, '');
          });
        } else {
          var attrStrings = placeholderReSplitter.split(attrValue);
          body.push(macro {
            var __b = new scout.html.part.BoolAttributePart(
              __e,
              $v{name},
              $v{attrStrings}
            );
            __parts.push(__b);
          });
        }
      } else if (attrName.startsWith('.')) {
        var name = attrName.substr(1);
        if (!placeholderRe.match(attrValue)) {
          body.push(macro __e.setProperty($v{name}, $v{attrValue}));
        } else {
          var attrStrings = placeholderReSplitter.split(attrValue);
          body.push(macro {
            var __com = new scout.html.part.PropertyCommitter(
              __e,
              $v{name},
              $v{attrStrings}
            );
            __parts = __parts.concat(cast __com.parts);
          });
        }
      } else if (placeholderRe.match(attrValue)) {
        var attrStrings = placeholderReSplitter.split(attrValue);
        body.push(macro {
          var __com = new scout.html.part.AttributeCommitter(
            __e,
            $v{attrName},
            $v{attrStrings}
          );
          __parts = __parts.concat(cast __com.parts);
        });
      } else {
        body.push(macro __e.setAttribute($v{attrName}, $v{attrValue}));
      }
    }

    for (child in node) {
      switch (child.nodeType) {
        case Element:
          body.push(macro __e.appendChild(${createElementFromXml(child)}));
        case PCData:
          body.push(handleDataNode(child));
        default:
          Context.error('Unexpected node: ${child.nodeType}', Context.currentPos());
      }
    }
    return macro {
      var __e = scout.html.Dom.createElement($v{name});
      $b{body}
      __e;
    }
  }

  static function handleDataNode(child:Xml) {
    function parseValue(value:String):Expr {
      if (placeholderRe.match(value)) {
        var parsed = placeholderRe.matchedLeft();
        var rest = parseValue(placeholderRe.matchedRight());
        return macro {
          var __n = js.Browser.document.createTextNode($v{parsed});
          __e.appendChild(__n);
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.appendInto(__e);
          ${rest};
          __e;
        }
      }
      return macro {
        var __n = js.Browser.document.createTextNode($v{value});
        __e.appendChild(__n);
        __e;
      }
    }
    return parseValue(child.nodeValue);
  } 

}
#end