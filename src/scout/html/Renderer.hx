package scout.html;

// #if js

import js.html.Node;
import js.html.Element;
import haxe.ds.Map;

class Renderer {
  
  static final parts = new Map<Node, Patcher>();

  public static function render(
    result:Result, 
    container:Element
  ) {
    var part = parts.get(container);
    if (part == null) {
      Dom.removeNodes(container, container.firstChild);
      part = new Patcher();
      parts.set(container, part);
      part.target.appendInto(container);
    }
    part.set(ValueResult(result));
    part.commit();
  }

}

// #else

// #end