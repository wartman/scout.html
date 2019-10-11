package scout.html.part;

import js.html.Node;
import scout.html.Component;
import scout.html.TemplateInstance;

class ComponentPart implements Part {

  final component:Component;
  var instance:TemplateInstance;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;
  public var value(get, set):Dynamic;
  public function set_value(v:Dynamic) {
    pendingValue = v;
    return v;
  }
  public function get_value() return currentValue;

  public function new(component:Component) {
    this.component = component;
    this.component._scout_setPart(this);
  }

  public function appendInto(container:Node) {
    if (instance == null) {
      var result = component.render();
      instance = result.factory.get();
      instance.update(result.values);
    }
    container.appendChild(instance.el);
  }

  public function commit() {
    while (Std.is(pendingValue, Directive)) {
      var directive:Directive = pendingValue;
      pendingValue = null;
      directive.handle(this);
    }
    if (pendingValue == null) {
      if (instance != null) {
        instance = null;
      }
      component.dispose();
    } else if (pendingValue != currentValue) {
      component._scout_setProperties(pendingValue);
      if (instance != null) {
        instance.update(component.render().values);
      }
    }
    currentValue = pendingValue;
  }

}
