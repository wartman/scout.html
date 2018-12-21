package scout.html;

import js.html.Node;
import js.html.Element;

private typedef ElementRefImpl = {
  ?custom:CustomElement,
  el:Element
};

// Note: only implements what is needed by the template.
abstract ElementRef(ElementRefImpl) {

  public function new(el:Element, ?custom:CustomElement) {
    this = {
      el: el,
      custom: custom
    };
  }

  @:from public static function fromElement(el:Element) {
    return new ElementRef(el);
  }

  @:from public static function fromCustomElement(custom:CustomElement) {
    return new ElementRef(custom.el, custom);
  }

  @:to public inline function toElement():Element {
    return this.el;
  }

  @:to public inline function toNode():Node {
    return cast this.el;
  }

  public inline function appendChild(el:Node) {
    this.el.appendChild(el);
  }

  public inline function setAttribute(name:String, value:String) {
    this.el.setAttribute(name, value);
  }

  public inline function setProperty(name:String, value:Dynamic) {
    if (this.custom != null) {
      Reflect.setField(this.custom, name, value);
      @:privateAccess this.custom.update(); // temp
    } else {
      Reflect.setField(this.el, name, value);  
    }
  }

}
