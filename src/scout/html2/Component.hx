package scout.html2;

#if !macro

import haxe.DynamicAccess;

@:autoBuild(scout.html2.Component.build())
class Component implements Part {

  @:noCompletion public final _scout_target:Target = new Target();
  @:noCompletion var _scout_context:Context;
  @:noCompletion var _scout_properties:DynamicAccess<Dynamic> = {};

  final public function new() {
    _scout_init();
  }

  public function set(value:Value) {
    switch value {
      case ValueDynamic(v): 
        _scout_properties = v;
      default:
        throw 'Invalid value type';
    }
  }

  @:noCompletion function _scout_setProperty(key:String, value:Dynamic) {
    _scout_properties.set(key, value);
    commit();
  }

  @:noCompletion function _scout_getProperty(key:String):Dynamic {
    return _scout_properties.get(key);
  }
  
  @:noCompletion function _scout_init() {
    // noop;
  }

  public function render():Result {
    return null;
  }

  public function commit() {
    if (_scout_properties == null) {
      dispose();
    } else if (_scout_context != null) {
      _scout_context.update(render().values);
    } else {
      var result = render();
      _scout_context = result.factory.get();
      _scout_context.update(result.values);
      _scout_target.insert(_scout_context.el);
    }
  }

  public function dispose() {
    _scout_context = null;
    _scout_properties = null;
  }

}

#else

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;

class Component {

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
            if (!Context.unify(t.toType(), Context.getType('scout.html2.Result'))) {
              Context.error('`children` must always be scout.html2.Result', f.pos);
            }
          default:
            Context.error('`children` must be a var', f.pos);
        }
      }
    }

    if (!hasChildren) {
      fields.push((macro class {
        @:attribute var children:scout.html2.Result;
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
