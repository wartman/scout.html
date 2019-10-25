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
    var cls = Context.getLocalClass().get();
    var exprs:Array<Expr> = [ for (node in nodes)
      generateNode(node, values)
    ].filter(e -> e != null);
    var eType = exprs.length == 1 ? exprs[0] : macro EFragment([ $a{exprs} ]);

    var name = 'TemplateFactory_' + getId(pos);

    Context.defineModule('scout.html.${name}', [

      macro class $name {
        
        public static final id:String = $v{name};

        public static function get() {
          return new scout.html.Context(id, ${eType});
        }

      }

    ], Context.getLocalImports());

    return macro @:pos(pos) new scout.html.Result(
      scout.html.$name,
      [ $a{values} ]
    );
  }

  function getId(pos:Position) {
    var cls = Context.getLocalClass().get();
    return cls.pack.concat([ cls.name ]).join('_') + '_' + pos.getInfos().max;
  }

  function generateNode(node:MarkupNode, values:Array<Expr>):Expr {
    if (node == null) return null;
    var pos = makePos(node.pos);
    return switch node.node {

      case MNode(name, attrs, children, false):
        var attrs:Array<Expr> = [ for (attr in attrs) 
          generateAttr(attr, values) 
        ];
        var children:Array<Expr> = children == null ? [] : [ for (c in children)
          generateNode(c, values)
        ].filter(e -> e != null);
        macro @:pos(pos) ENative($v{name}, [ $a{attrs} ], [ $a{children} ]);
        
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
        if (children != null && children.length > 0) {
          fields.push({
            field: 'children',
            expr: new DomGenerator(children, makePos(node.pos)).generate()
          });
        }
        var value:Expr = {
          expr: EObjectDecl(fields),
          pos: pos
        };

        if (Context.unify(type, Context.getType('scout.html.Result'))) {
          values.push(macro @:pos(pos) ValueResult(new $tp($value)));
          macro @:pos(pos) EPart;
        } else {
          // TODO: We need to type check the value here!
          if (!Context.unify(type, Context.getType('scout.html.Component'))) {
            Context.error('Components must implement scout.html.Component', pos);
          }
          values.push(macro @:pos(pos) ValueDynamic(${value}));
          macro @:pos(pos) EComponent(new $tp());
        }

      case MCode(v):
        values.push(makeValue(Context.parse(v, pos)));
        macro @:pos(pos) EPart;

      case MText(value):
        macro @:pos(pos) EText($v{value});

      case MFor(it, children):
        switch Context.parse(it, pos) {
          case macro $i{name} in $target:
            values.push(macro @:pos(pos) ValueIterable([ for ($i{name} in ${target}) ValueResult(${new DomGenerator(children, pos).generate()}) ]));
          default:
            Context.error('Invalid loop iterator', pos);
        }
        macro @:pos(pos) EPart;

      case MIf(cond, passing, failed):
        var expr = Context.parse(cond, pos);
        var ifBranch = new DomGenerator(passing, pos).generate();
        var elseBranch = failed != null 
          ? new DomGenerator(failed, makePos(failed[0].pos)).generate()
          : macro null;
        values.push(macro @:pos(pos) if (${expr}) ValueResult(${ifBranch}) else ValueResult(${elseBranch}));
        macro @:pos(pos) EPart;

      case MFragment(children):
        var exprs:Array<Expr> = [ for (c in children) generateNode(c, values) ];
        return macro @:pos(pos) EFragment([ $a{exprs} ]);

      case MNone: null;

    }
  }

  function generateAttr(attr:MarkupAttribute, values:Array<Expr>):Expr {
    var pos = makePos(attr.pos);
    if (attr.name.startsWith('on')) {
      return switch attr.value {
        case Raw(v):
          Context.error('Events can only recieve functions', pos);
        case Code(v):
          values.push(makeValue(Context.parse(v, pos)));
          macro @:pos(pos) {
            name: $v{attr.name},
            value: AttrPart
          };
      }
    } else {
      return switch attr.value {
        case Raw(v):
          macro @:pos(pos) {
            name: $v{attr.name},
            value: AttrConstant($v{v})
          };
        case Code(v):
          values.push(makeValue(Context.parse(v, pos)));
          macro @:pos(pos) @:pos(pos) {
            name: $v{attr.name},
            value: AttrPart
          };
      }
    }
    return macro null;
  }

  function makeValue(expr:Expr):Expr {
    // todo: this is being done because of the way I'm handing "for" loops.
    // It is probably prone to big bugs. Think of a way to type the expr.
    try {
      if (Context.unify(Context.typeof(expr), Context.getType('scout.html.Result'))) {
        return macro @:pos(expr.pos) ValueResult(${expr});
      } 
    } catch(e:Dynamic) {
      // noop
    }
    return switch expr.expr {
      case EArrayDecl(values): 
        var exprs = [ for (v in values) makeValue(v) ];
        macro @:pos(expr.pos) ValueIterable([ $a{exprs} ]);
      default:
        macro @:pos(expr.pos) ValueDynamic(${expr});
    }
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
