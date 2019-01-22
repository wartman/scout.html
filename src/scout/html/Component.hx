package scout.html;

import haxe.ds.Map;

// FOR TESTING ONLY

@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component 
  implements TemplateResult.TemplateResultObject 
  implements TemplateUpdater
{

  static var _scout_componentIds:Int = 0;
  public final _scout_cid:Int = _scout_componentIds++;
  public final _scout_properties:Map<String, Dynamic> = new Map();
  var _scout_template:Template;
  var _scout_result:TemplateResult;
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

  public function getFactory() {
    if (_scout_result == null) {
      _scout_result = render();
    }
    return _scout_result.getFactory();
  }

  public function getValues() {
    return render().getValues();
  }

  public function update() {
    if (shouldRender() && _scout_template != null) {
      var res = render();
      _scout_template.update(res.getValues());
    }
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render():Null<TemplateResult> {
    return null;
  }

}
