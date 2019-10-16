package scout.html;

import haxe.DynamicAccess;

@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component implements Part {
  
  @:noCompletion public final _scout_target:Target = new Target();
  @:noCompletion var _scout_properties:DynamicAccess<Dynamic> = {};
  @:noCompletion var _scout_instance:TemplateInstance;

  final public function new() {
    _scout_init();
  }
  
  public function setValue(props:Dynamic) {
    _scout_properties = props;
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

  public function commit() {
    if (_scout_properties == null) {
      dispose();
    } else if (_scout_instance != null) {
      _scout_instance.update(render().values);
    } else {
      var result = render();
      _scout_instance = result.factory.get();
      _scout_instance.update(result.values);
      _scout_target.insert(_scout_instance.el);
    }
  }
  
  public function render():TemplateResult {
    return null;
  }

  public function dispose():Void {
    _scout_instance = null;
    _scout_properties = null;
  }

}
