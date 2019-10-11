#if macro

package scout.html.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import scout.html.dsl.MarkupParser;

using StringTools;
using haxe.macro.PositionTools;

class MarkupGenerator {
  
  final nodes:Array<MarkupNode>;
  final pos:Position;

  public function new(nodes:Array<MarkupNode>, pos:Position) {
    this.nodes = nodes;
    this.pos = pos;
  }

  public function generate():Expr {
    var values:Array<Expr> = [];
    var exprs:Array<Expr> = [ for (node in nodes) 
      generateNode(node, values)
    ].filter(e -> e != null);
    var name = 'TemplateFactory_' + getId(pos);

    Context.defineModule('scout.html.${name}', [

      macro class $name implements scout.html.TemplateFactory {
        
        public final id:String = $v{name};

        public function new() {}

        public function get() {
          var __parts:Array<Null<scout.html.Part>> = [];
          var __e = js.Browser.document.createDocumentFragment();
          $b{exprs};
          var __t = new scout.html.TemplateInstance(id, cast __e, __parts);
          return __t;
        }

      }

    ], Context.getLocalImports());

    return macro @:pos(pos) new scout.html.TemplateResult(
      new scout.html.$name(),
      [ $a{values} ]
    );
  }

  function getId(pos:Position) {
    var cls = Context.getLocalClass().get();
    return cls.pack.concat([ cls.name ]).join('_') + '_' + pos.getInfos().min;
  }

  function generateNode(node:MarkupNode, values:Array<Expr>):Expr {
    var pos = makePos(node.pos);
    return switch node.kind {
      case Node(name):
        var attrs = [ for (attr in node.attributes) 
          generateAttr(attr, values) 
        ];
        var children = [ for (c in node.children)
          generateNode(c, values)
        ].filter(e -> e != null);
        macro @:pos(pos) __e.appendChild({
          var __e = scout.html.Dom.createElement($v{name});
          $b{attrs}
          $b{children};
          __e;
        });
      case CodeBlock(v):
        values.push(Context.parse(v, pos));
        macro @:pos(pos) {
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.appendInto(__e);
          __e;
        }
      case Text(value):
        macro @:pos(pos) __e.appendChild(scout.html.Dom.createTextNode($v{value}));
      case None: null;
    }
  }

  function generateAttr(attr:Attribute, values:Array<Expr>):Expr {
    var pos = makePos(attr.pos);
    if (attr.name.startsWith('on')) {
      var event = attr.name.substr(2).toLowerCase();
      return switch attr.value {
        case Raw(v):
          Context.error('Events can only recieve functions', pos);
        case Code(v):
          values.push(Context.parse(v, pos));
          macro @:pos(pos) __parts.push(new scout.html.part.EventPart(__e, $v{event}));
      }
    } else if (attr.name.startsWith('is')) {
      var name = attr.name.substr(2).toLowerCase();
      return switch attr.value {
        case Raw(v): 
          macro @:pos(pos) if (!!$v{v}) __e.setAttribute($v{name}, $v{name});
        case Code(v):
          values.push(Context.parse(v, pos));
          macro @:pos(pos) __parts.push(new scout.html.part.BoolAttributePart(__e, $v{name}));
      }
    } else if (attr.name.startsWith('.')) {
      var name = attr.name.substr(1);
      return switch attr.value {
        case Raw(v):
          macro @:pos(pos) Reflect.setProperty(__e, $v{name}, $v{v});
        case Code(v):
          values.push(Context.parse(v, pos));
          macro @:pos(pos) __parts.push(new scout.html.part.PropertyPart(__e, $v{name}));
      }
    } else {
      return switch attr.value {
        case Raw(v):
          macro @:pos(pos) __e.setAttribute($v{attr.name}, $v{v});
        case Code(v):
          values.push(Context.parse(v, pos));
          macro @:pos(pos) __parts.push(new scout.html.part.AttributePart(__e, $v{attr.name}));
      }
    }
    return macro null;
  }

  function makePos(pos:MarkupPos):Position {
    return Context.makePosition({
      min: pos.min,
      max: pos.max,
      file: this.pos.getInfos().file
    });
  }

}

#end
