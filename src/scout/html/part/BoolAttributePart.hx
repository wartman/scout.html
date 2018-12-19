package scout.html.part;

import js.html.Element;
import scout.html.Part;

class BoolAttributePart implements Part {

  final element:Element;
  final name:String;
  final strings:Array<String>;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;
  public var value(get, set):Dynamic;
  public function set_value(value:Dynamic) {
    pendingValue = value;
    return value;
  }
  public function get_value() return currentValue;

  public function new(element:Element, name:String, strings:Array<String>) {
    this.element = element;
    this.name = name;
    this.strings = strings;
  }

  public function commit() {
    if (pendingValue == null) return;
    var value:Bool = !!pendingValue;
    if (currentValue != value) {
      if (value) {
        element.setAttribute(name, '');
      } else {
        element.removeAttribute(name);
      }
    }
    currentValue = value;
    pendingValue = null;
  }

}
