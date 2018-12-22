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

  public function appendChild(child:Node) {
    if (this.custom != null) {
      return this.custom.appendChild(child);
    }
    return this.el.appendChild(child);
  }

  public function setAttribute(name:String, value:String) {
    if (this.custom != null) {
      this.custom.setAttribute(name, value);
    } else {
      this.el.setAttribute(name, value);
    }
  }

  public function setProperty(name:String, value:Dynamic) {
    if (this.custom != null) {
      Reflect.setProperty(this.custom, name, value);
    } else {
      Reflect.setField(this.el, name, value);  
    }
  }

}
