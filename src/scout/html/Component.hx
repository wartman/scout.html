package scout.html;

import haxe.DynamicAccess;

using Reflect;

@:allow(scout.html.Part)
@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component {

  final public function new() {}

  @:noCompletion var _scout_part:Part;
  @:noCompletion var _scout_properties:DynamicAccess<Dynamic> = {};

  @:noCompletion function _scout_setPart(part:Part):Void {
    _scout_part = part;
  }
  
  @:noCompletion function _scout_setProperties(props:Dynamic):Void {
    _scout_properties = props;
  }

  @:noCompletion function _scout_setProperty(key:String, value:Dynamic) {
    if (_scout_part != null) {
      var props = _scout_properties.copy();
      props.set(key, value);
      _scout_part.value = props;
      _scout_part.commit();
    } else {
      _scout_properties.set(key, value);
    }
  }

  @:noCompletion function _scout_getProperty(key:String):Dynamic {
    return _scout_properties.get(key);
  }
  
  public function render():TemplateResult {
    return null;
  }

  public function dispose():Void {
    // noop
  }

}
