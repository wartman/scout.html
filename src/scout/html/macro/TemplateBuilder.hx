#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using Xml;
using haxe.macro.MacroStringTools;

class TemplateBuilder {

  static final placeholder:String = '{{__scout__}}';
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
        var key = placeholder;
        parts += key;
        values.push(e);
    }
    return parts;
  }

  static function secondPass(str:String, values:Array<Expr>) {
    var root = Xml.parse(str);
    var exprs:Array<Expr> = [];
    for (node in root) switch (node.nodeType) {
      case Element: exprs.push(macro __e.appendChild(${createElementFromXml(node)}));
      case PCData: exprs.push(handleDataNode(node));
      default:
    }
    var name = 'TemplateFactory_' + (Math.ceil(Math.random() * 1000));
    Context.defineModule('scout.html.${name}', [ macro class $name implements scout.html.TemplateFactory {

      public final id:String = $v{name};

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

    for (attrName in node.attributes()) {
      var attrValue:String = node.get(attrName);
      if (attrName.startsWith('on:')) {
        var event = attrName.substr(3);
        body.push(macro {
          var __ev = new scout.html.part.EventPart(
            cast __e,
            $v{event}
          );
          __parts.push(__ev);
        });
      } else if (attrName.startsWith('is:')) {
        var name = attrName.substr(3);
        var attrStrings = attrValue.split(placeholder);
        body.push(macro {
          var __b = new scout.html.part.BoolAttributePart(
            cast __e,
            $v{name},
            $v{attrStrings}
          );
          __parts.push(__b);
        });
      } else if (attrName.startsWith('.')) {
        var name = attrName.substr(1);
        var attrStrings = attrValue.split(placeholder);
        body.push(macro {
          var __com = new scout.html.part.PropertyCommitter(
            cast __e,
            $v{name},
            $v{attrStrings}
          );
          for (__p in __com.parts) {
            __parts.push(__p);
          }
        });
      } else if (attrValue.indexOf(placeholder) >= 0) {
        var attrStrings = attrValue.split(placeholder);
        body.push(macro {
          var __com = new scout.html.part.AttributeCommitter(
            cast __e,
            $v{attrName},
            $v{attrStrings}
          );
          for (__p in __com.parts) {
            __parts.push(__p);
          }
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
      var __e = js.Browser.document.createElement($v{name});
      $b{body}
      __e;
    }
  }

  static function handleDataNode(child:Xml) {
    function parseValue(value:String):Expr {
      if (value.indexOf(placeholder) >= 0) {
        var start = value.indexOf(placeholder);
        var end = start + placeholder.length;
        var parsed = value.substr(0, start);
        var key = value.substr(start, end);
        var rest = parseValue(value.substr(end));
        return macro {
          var __n = js.Browser.document.createTextNode($v{parsed});
          __e.appendChild(__n);
          var __nc = scout.html.Dom.createMarker();
          __e.appendChild(__nc);
          __e.appendChild(scout.html.Dom.createMarker());
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.insertAfterNode(__nc);
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