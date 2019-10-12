#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;

class ComponentBuilder {
  
  public static function build() {
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];
    var hasChildren:Bool = false;
    var initializers:Array<Expr> = [];

    for (f in fields) {
      if (f.name == 'children') {
        switch (f.kind) {
          case FVar(t, _):
            hasChildren = true;
            if (!Context.unify(t.toType(), Context.getType('scout.html.TemplateResult'))) {
              Context.error('`children` must always be scout.html.TemplateResult', f.pos);
            }
          default:
            Context.error('`children` must be a var', f.pos);
        }
      }
    }

    if (!hasChildren) {
      fields.push((macro class {
        @:attribute var children:scout.html.TemplateResult;
      }).fields[0]);
    }
    
    for (f in fields) switch (f.kind) {
      case FVar(t, e):
        if (f.meta.exists(m -> m.name == ':attribute' || m.name == ':attr')) {
          f.kind = FProp('get', 'set', t, null);
          var name = f.name;
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          if (e != null) {
            initializers.push(macro this._scout_properties.set($v{name}, $e));
          }
          newFields = newFields.concat((macro class {
            function $setName(value) {
              _scout_setProperty($v{name}, value);
              return value;
            }
            function $getName() return _scout_getProperty($v{name});
          }).fields);
        }
      default:
    }

    newFields = newFields.concat((macro class {
      override function _scout_init() {
        $b{initializers};
      }
    }).fields);
    
    return fields.concat(newFields);
  }

}
#end