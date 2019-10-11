package scout.html.part;

import js.html.Element;
import scout.html.Part;
import scout.html.Directive;

class AttributePart implements Part {
  
  final name:String;
  final element:Element;
  public var dirty:Bool = true;
  @:isVar public var value(get, set):Dynamic;
  public function set_value(value:Dynamic) {
    if (value != this.value) {
      this.value = value;
      if (!Std.is(this.value, Directive)) {
        dirty = true;
      }
    }
    return value;
  }
  public function get_value() return this.value;

  public function new(element:Element, name:String) {
    this.element = element;
    this.name = name;
  }

  public function commit() {
    handleDirective();
    if (dirty) {
      dirty = false;
      if (value == null) {
        element.removeAttribute(name);
      } else {
        var out = Std.is(value, Array) ? value.join('') : value;
        element.setAttribute(name, out);
      }
    }
  }

  function handleDirective() {
    while (Std.is(value, Directive)) {
      var directive:Directive = value;
      value = null;
      directive.handle(this);
    }
  }

}
