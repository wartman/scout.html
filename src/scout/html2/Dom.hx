package scout.html2;

import js.Browser;
import js.html.Node;

class Dom {

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

  public static inline function createMarker() {
    return Browser.document.createComment('');
  }

  public static inline function createElement(name:String) {
    return Browser.document.createElement(name);
  }

  public static inline function createTextNode(value:String) {
    return Browser.document.createTextNode(value);
  }

}
