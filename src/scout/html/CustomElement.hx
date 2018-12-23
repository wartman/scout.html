package scout.html;

import js.html.Element;
import js.html.Node;

@:autoBuild(scout.html.macro.CustomElementBuilder.build())
class CustomElement {

  public final el:Element;
  public static var elementName(get, never):String;
  public static function get_elementName() return '';

  public function new(el:Element) {
    this.el = el;
  }

  ///// FORWARDING (TEMP UNTIL WE CAN EXTEND HTMLELEMENT DIRECTLY) /////

  public inline function getAttribute(name:String)
    return el.getAttribute(name);

  public inline function setAttribute(name:String, value:String)
    el.setAttribute(name, value);
  
  public inline function addEventListener(type, listener, capture:Bool = false)
    el.addEventListener(type, listener, capture);

  public inline function removeEventListener(type, listener, capture:Bool = false)
    el.removeEventListener(type, listener, capture);
  
  public inline function querySelector(selectors)
    return el.querySelector(selectors);

  public inline function querySelectorAll(selectors)
    return el.querySelectorAll(selectors);

  public inline function appendChild(child:Node):Node {
    return el.appendChild(child);
  }

  public inline function remove()
    el.remove();

  ///// END /////

}
