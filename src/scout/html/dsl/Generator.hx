package scout.html.dsl;

import haxe.macro.Expr;
import haxe.macro.Context;
import scout.html.dsl.Node;

using haxe.macro.MacroStringTools;

class Generator {

  static final PARTS:String = '__parts';
  static final NODE:String = '__e';
  static var id:Int = 0;

  static function getId() {
    return id += 1;
  }
  
  var root:Node;
  var values:Array<Expr> = [];

  public function new(root:Node) {
    this.root = root;
  }

  public function generate() {
    var body = node(root);
    var name = 'DslTemplateFactory_' + getId();
    Context.defineModule('scout.html.${name}', [ macro class $name implements scout.html.TemplateFactory {

      public final id:String = $v{name};

      public function new() {}

      public function get() {
        var $PARTS:Array<Null<scout.html.Part>> = [];
        var $NODE = js.Browser.document.createDocumentFragment();
        ${body};
        return new scout.html.Template(id, cast $i{NODE}, $i{PARTS});
      }

    } ], Context.getLocalImports());
      
    return macro new scout.html.TemplateResult(new scout.html.$name(), [ $a{values} ]);
  }
  
  function yieldAttr(name:String, expr:Expr, hasPart:Bool = false):Expr {
    if (hasPart) {
      var strings = handleAttrOrPropValue(expr);
      if (strings.length == 0) {
        strings = [ macro '', macro '' ];
      }
      return macro {
        var __part = new scout.html.part.AttributeCommitter(
          $i{NODE},
          $v{name},
          [ $a{strings} ] 
        );
        $i{PARTS} = $i{PARTS}.concat(cast __part.parts);
      }
    }
    return macro $i{NODE}.setAttribute($v{name}, ${expr});
  }
  
  function yieldProp(name:String, expr:Expr, hasPart:Bool = false):Expr {
    if (hasPart) {
      var strings = handleAttrOrPropValue(expr);
      if (strings.length == 0) {
        strings = [ macro '', macro '' ];
      }
      return macro {
        var __part = new scout.html.part.PropertyCommitter(
          $i{NODE},
          $v{name},
          [ $a{strings} ] 
        );
        $i{PARTS} = $i{PARTS}.concat(cast __part.parts);
      }
    }
    return macro $i{NODE}.setProperty($v{name}, ${expr});
  }

  function yieldChild(expr:Expr):Expr {
    return macro $i{NODE}.appendChild(${expr});
  }

  function hasParts(value:Expr) {
    return switch (value.expr) {
      case EConst(CString(s)):
        var expr = s.formatString(value.pos);
        switch (expr.expr) {
          case EConst(CString(_)): 
            false; //???
          default:
            value = cast expr;
            true;
        }
      default: true;
    }
  }

  function node(n:Node):Expr { 
    var expr = switch (n) {
      case NodeNone: 
        macro null;
      case NodeId(e):
        identifier(e);
      case NodeTag(name, kind, body):
        yieldChild(tag(name, kind, body));
      case NodeAttribute(name, value):
        attr(name, value);
      case NodeValue(e):
        value(e);
      case NodeIf(cond, pass, fail):
        conditional(cond, pass, fail);
      case NodeFor(cond, body):
        iter(cond, body);
      case NodeFragment(body):
        var b = body.map(node);
        macro $b{b};
    }
    return expr;
  }

  function tag(tag:Located<String>, kind:NodeKind, children:Array<Node>):Expr {
    var name = tag.value;
    var body = children.map(node);
    var create = kind == KindTag
      ? macro @:pos(tag.pos) scout.html.Dom.createElement($v{name.split('.').join('-')})
      : macro @:pos(tag.pos) scout.html.Dom.createElement($p{name.split('.')}.get_elementName());
    return macro {
      var $NODE = ${create};
      $b{body};
      $i{NODE};
    }
  }

  function attr(n:Located<String>, value:Expr) {
    var name = n.value;
    var hasPart = hasParts(value);

    if (name.indexOf('.') >= 0) {
      var parts = name.split('.');
      var prefix = parts.shift();
      var parsedName = parts.join('-');
      switch (prefix) {
        case 'on':
          values.push(value);
          return macro {
            var __part = new scout.html.part.EventPart(
              $i{NODE},
              $v{parsedName}
            );
            $i{PARTS}.push(__part);
          }
        case 'is':
          if (!hasPart) {
            return macro {
              var __truthy:Bool = !!${value};
              if (__truthy) $i{NODE}.setAttribute($v{parsedName}, '');
            } 
          } else {
            values.push(value);
            return macro {
              var __part = new scout.html.part.BoolAttributePart(
                $i{NODE},
                $v{parsedName},
                ['', '']
              );
              $i{PARTS}.push(__part);
            }
          }
        case 'props':
          return yieldProp(parsedName, value, hasPart);
      }
    }

    name = name.split('.').join('-');
    return yieldAttr(name, value, hasPart);
  }

  function identifier(e:Expr) {
    switch (e.expr) {
      case EConst(CString(s)):
        if (hasParts(e)) {
          var expr = s.formatString(e.pos);
          var strings = handleAttrOrPropValue(cast expr);
          if (strings.length == 0) {
            strings = [ macro '', macro '' ];
          }
          return macro {
            var __part = new scout.html.part.ClassAttributeCommitter(
              $i{NODE},
              [ $a{strings} ] 
            );
            $i{PARTS} = $i{PARTS}.concat(cast __part.parts);
          }
        } else {
          return macro scout.html.Dom.setElementIdentifiers($i{NODE}, ${e});
        }
      default:
        values.push(e);
        return macro {
          var __part = new scout.html.part.ClassAttributeCommitter(
            $i{NODE},
            [ '', '' ] 
          );
          $i{PARTS} = $i{PARTS}.concat(cast __part.parts);
        }
    }
  }

  function value(expr:Expr) {
    return switch (expr.expr) {
      case EConst(CString(s)):
        var e = s.formatString(expr.pos);
        var body = handleValue(cast e);
        macro {
          $b{body};
          $i{NODE};
        }
      default:
        var body = handleValue(expr);
        macro {
          $b{body};
          $i{NODE};
        }
    }
  }
  
  function handleAttrOrPropValue(e:Expr):Array<Expr> {
    var parts:Array<Expr> = [];
    switch(e.expr) {
      case EBinop(OpAdd, e1, e2): 
        parts = parts
          .concat(handleAttrOrPropValue(e1))
          .concat(handleAttrOrPropValue(e2));
      case EConst(CString(s)): 
        parts.push(macro $v{s});
      default:
        values.push(e);
    }
    return parts;
  }

  function handleValue(e:Expr):Array<Expr> {
    var parts:Array<Expr> = [];
    switch(e.expr) {
      case EBinop(OpAdd, e1, e2): 
        parts = parts
          .concat(handleValue(e1))
          .concat(handleValue(e2));
      case EConst(CString(s)): 
        parts.push(macro {
          var __txt = js.Browser.document.createTextNode($v{s});
          $i{NODE}.appendChild(__txt);  
        });
      default:
        values.push(e);
        parts.push(macro {
          var __part = new scout.html.part.NodePart();
          $i{PARTS}.push(__part);
          __part.appendInto($i{NODE});
        });
    }
    return parts;
  }

  function conditional(cond:Expr, pass:Node, fail:Node) {
    var passBranch = new Generator(pass).generate();
    var failBranch = new Generator(fail).generate();
    values.push(macro if (${cond}) ${passBranch} else ${failBranch});
    return macro {
      var __part = new scout.html.part.NodePart();
      $i{PARTS}.push(__part);
      __part.appendInto($i{NODE});
    }
  }

  function iter(cond:Expr, body:Node) {
    var iterator = new Generator(body).generate();
    values.push(macro [ for (${cond}) ${iterator} ]);
    return macro {
      var __part = new scout.html.part.NodePart();
      $i{PARTS}.push(__part);
      __part.appendInto($i{NODE});
    }
  }

}
