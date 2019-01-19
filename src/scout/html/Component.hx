package scout.html;

import haxe.ds.Map;

@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component {

  static var _scout_componentIds:Int = 0;
  public final _scout_cid:Int = _scout_componentIds++;
  public final _scout_properties:Map<String, Dynamic> = new Map();
  var _scout_template:Template;
  var _scout_silent:Bool = false;
  
  public function setProperty(name:String, value:Dynamic) {
    _scout_properties.set(name, value);
    if (!_scout_silent) {
      update();
    }
  }

  public function getProperty(name:String) {
    return _scout_properties.get(name);
  }

  public function update(?props:Map<String, Dynamic>) {
    _scout_silent = true;
    if (props != null) {
      for (key in props.keys()) {
        setProperty(key, props.get(key));
      }
    }
    if (shouldRender() && _scout_template != null) {
      var res = render();
      _scout_template.update(res.values);
    }
    _scout_silent = false;
  }

  public function _scout_render():Null<TemplateResult> {
    var res = render();
    if (res != null) {
      var cached = new TemplateResult(
        new StaticTemplateFactory(res.factory),
        res.values
      );
      _scout_template = cached.factory.get();
      return cached;
    }
    return res;
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render():Null<TemplateResult> {
    return null;
  }

}
