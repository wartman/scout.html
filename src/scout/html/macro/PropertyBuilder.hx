#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class PropertyBuilder {

  public static function build() {
    var fields = Context.getBuildFields();
    var newFields:Array<Field> = [];

    for (f in fields) switch (f.kind) {
      case FVar(t, e):
        if (f.meta.exists(m -> m.name == ':property' || m.name == ':prop')) {
          f.kind = FProp('get', 'set', t, e);
          var name = f.name;
          var getName = 'get_${name}';
          var setName = 'set_${name}';
          newFields = newFields.concat((macro class {
            function $setName(value) {
              setProperty($v{name}, value);
              return value;
            }
            function $getName() return getProperty($v{name});
          }).fields);
        }
        // if (f.meta.exists(m -> m.name == ':attribute' || m.name == ':attr')) {
        //   f.kind = FProp('get', 'set', t, e);
        //   var params = f.meta.find(m -> m.name == ':attribute' || m.name == ':attr').params;
        //   var name = f.name;
        //   var attrName = params.length > 0 ? params[0] : macro $v{name};
        //   var getName = 'get_${name}';
        //   var setName = 'set_${name}';
        //   newFields = newFields.concat((macro class {
        //     function $setName(value) {
        //       setAttribute(${attrName}, value);
        //       return value;
        //     }
        //     function $getName() return getAttribute($v{name});
        //   }).fields);
        // }
      default:
    }

    return fields.concat(newFields);
  }

}
#end
