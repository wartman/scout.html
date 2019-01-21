package scout.html;

import haxe.ds.Map;

@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component implements Renderable implements Updateable {

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
  
  public function setTemplate(template:Template) {
    _scout_template = template;
  }

  public function update() {
    if (shouldRender() && _scout_template != null) {
      var res = render();
      _scout_template.update(res.values);
    }
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render():Null<TemplateResult> {
    return null;
  }

}
