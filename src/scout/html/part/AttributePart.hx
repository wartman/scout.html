package scout.html.part;

import scout.html.dom.Element;
import scout.html.Part;
import scout.html.Directive;

class AttributePart implements Part {
  
  final name:String;
  final element:Element;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;

  public function new(element:Element, name:String) {
    this.element = element;
    this.name = name;
  }

  public function setValue(value:Dynamic) {
    if (value != currentValue) {
      pendingValue = value;
    }
  }

  public function commit() {
    handleDirective();
    if (pendingValue != currentValue) {
      if (pendingValue == null) {
        element.removeAttribute(name);
      } else {
        var out = Std.is(pendingValue, Array) ? pendingValue.join('') : pendingValue;
        element.setAttribute(name, out);
      }
    }
    currentValue = pendingValue;
  }

  function handleDirective() {
    while (Std.is(pendingValue, Directive)) {
      var directive:Directive = pendingValue;
      pendingValue = null;
      directive.handle(this);
    }
  }

}
