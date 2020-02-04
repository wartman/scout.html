package scout.html;

import js.html.*;

class DomTools {

  public static function removeNodes(
    container:Node,
    ?startNode:Node,
    ?endNode:Node
  ) {
    var node = startNode;
    while (node != endNode && node != null) {
      var n = node.nextSibling;
      container.removeChild(node);
      node = n;
    }
  }

  public static inline function createMarker():Node {
    return js.Browser.document.createComment('');
  }

  public static inline function createElement(name:String) {
    return js.Browser.document.createElement(name);
  }

  public static inline function createTextNode(value:String) {
    return js.Browser.document.createTextNode(value);
  }

}
