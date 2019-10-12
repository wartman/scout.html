#if macro

package scout.html.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import scout.html.dsl.MarkupNode;

using StringTools;
using haxe.macro.PositionTools;

class DomGenerator {
  
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
    return cls.pack.concat([ cls.name ]).join('_') + '_' + pos.getInfos().max;
  }

  function generateNode(node:MarkupNode, values:Array<Expr>):Expr {
    var pos = makePos(node.pos);
    return switch node.node {

      case MNode(name, attrs, children, false):
        var attrs = [ for (attr in attrs) 
          generateAttr(attr, values) 
        ];
        var children = [ for (c in children)
          generateNode(c, values)
        ].filter(e -> e != null);
        macro @:pos(pos) __e.appendChild({
          var __e = scout.html.Dom.createElement($v{name});
          $b{attrs}
          $b{children};
          __e;
        });
        
      case MNode(name, attrs, children, true):
        var tp = if (name.contains('.')) {
          var pack = name.split('.');
          var clsName = pack.pop();
          { pack: pack, name: clsName };
        } else { pack: [], name: name };
        var type = try {
          Context.getType(name);
        } catch(e:String) {
          Context.error(e, pos);
        }

        var fields = [ for (attr in attrs) 
          {
            field: attr.name,
            expr: switch attr.value {
              case Raw(v): macro @:pos(pos) $v{v};
              case Code(v): Context.parse(v, pos);
            }
          }
        ];
        if (children.length > 0) {
          fields.push({
            field: 'children',
            expr: new DomGenerator(children, makePos(node.pos)).generate()
          });
        }
        var value:Expr = {
          expr: EObjectDecl(fields),
          pos: pos
        };

        if (Context.unify(type, Context.getType('scout.html.TemplateResult'))) {
          values.push(macro new $tp($value));
          macro @:pos(pos) {
            var __p = new scout.html.part.NodePart();
            __parts.push(__p);
            __p.appendInto(__e);
            __e;
          }
        } else {
          if (!Context.unify(type, Context.getType('scout.html.Component'))) {
            Context.error('Components must implement scout.html.Component', pos);
          }
          values.push(value);
          macro @:pos(pos) {
            var __p = new scout.html.part.ComponentPart(new $tp());
            __parts.push(__p);
            __p.appendInto(__e);
            __e;
          }
        }

      case MCode(v):
        values.push(Context.parse(v, pos));
        macro @:pos(pos) {
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.appendInto(__e);
          __e;
        }

      case MText(value):
        macro @:pos(pos) __e.appendChild(scout.html.Dom.createTextNode($v{value}));
      
      case MFor(it, children):
        var expr = Context.parse(it, pos);
        var children = new DomGenerator(children, pos).generate();
        values.push(macro @:pos(pos) [ for (${expr}) ${children} ]);
        macro @:pos(pos) {
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.appendInto(__e);
          __e;
        }

      case MIf(cond, passing, failed):
        var expr = Context.parse(cond, pos);
        var ifBranch = new DomGenerator(passing, pos).generate();
        var elseBranch = failed != null 
          ? new DomGenerator(failed, makePos(failed[0].pos)).generate()
          : macro null;
        values.push(macro @:pos(pos) if (${expr}) ${ifBranch} else ${elseBranch});
        macro @:pos(pos) {
          var __p = new scout.html.part.NodePart();
          __parts.push(__p);
          __p.appendInto(__e);
          __e;
        }

      case MNone: null;

    }
  }

  function generateAttr(attr:MarkupAttribute, values:Array<Expr>):Expr {
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

  function makePos(pos:MarkupPosition):Position {
    return Context.makePosition({
      min: pos.min,
      max: pos.max,
      file: this.pos.getInfos().file
    });
  }

}

#end
