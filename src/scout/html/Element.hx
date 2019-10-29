package scout.html;

#if js

import js.html.Node;
import js.html.Element as JsElement;

@:forward
abstract Element(JsElement) from JsElement to JsElement to Node {

  // Probably a bit iffy
  @:from public static inline function ofNode(node:Node) {
    return cast node;
  }

}

#else

abstract Element(String) from String to String {}

#end
