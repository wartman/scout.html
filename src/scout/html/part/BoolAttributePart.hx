package scout.html.part;

import js.html.Element;
import scout.html.Part;
import scout.html.Directive;

class BoolAttributePart implements Part {

  final element:Element;
  final name:String;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;

  public function new(element:Element, name:String) {
    this.element = element;
    this.name = name;
  }

  public function setValue(value:Dynamic) {
    pendingValue = value;
  }

  public function commit() {
    while (Std.is(pendingValue, Directive)) {
      var directive:Directive = pendingValue;
      pendingValue = null;
      directive.handle(this);
    }

    if (pendingValue == null) return;
    var value:Bool = !!pendingValue;
    if (currentValue != value) {
      if (value) {
        element.setAttribute(name, name);
      } else {
        element.removeAttribute(name);
      }
    }
    
    currentValue = value;
    pendingValue = null;
  }

}
