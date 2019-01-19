#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class ComponentBuilder {

  public static function build() {
    var fields = Context.getBuildFields();
    var props:Array<Field> = [];
    var newFields:Array<Field> = [];
    var initializers:Array<Expr> = [];

    for (f in fields) switch (f.kind) {
      case FVar(t, e):
        if (f.meta.exists(m -> m.name == ':property' || m.name == ':prop')) {
          f.kind = FProp('get', 'set', t, null);
          var name = f.name;
          var isOptional = f.meta.exists(m -> m.name == ':optional');
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          if (e != null) {
            initializers.push(macro this.$name = props.$name == null ? $e : props.$name);
          } else {
            initializers.push(macro this.$name = props.$name);
          }
          props.push({
            name: name,
            kind: FVar(t, null),
            access: [ APublic ],
            meta: isOptional ? [ { name: ':optional', pos: f.pos } ] : [],
            pos: f.pos
          });
          newFields = newFields.concat((macro class {
            function $setName(value) {
              setProperty($v{name}, value);
              return value;
            }
            function $getName() return getProperty($v{name});
          }).fields);
        }
      case FFun(_):
        if (f.meta.exists(m -> m.name == ':init')) {
          var name = f.name;
          initializers.push(macro this.$name());
        }
      default:
    }

    var constructorAttrs = TAnonymous(props);
    newFields = newFields.concat((macro class {

      public function new(props:$constructorAttrs) {
        _scout_silent = true;
        $b{initializers};
        _scout_silent = false;
      }

    }).fields);

    return fields.concat(newFields);
  }

}
#end
