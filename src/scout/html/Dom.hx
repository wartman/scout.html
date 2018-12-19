package scout.html;

import js.Browser;
import js.html.Node;

class Dom {

  public static function removeNodes(
    container:Node,
    ?startNode:Node,
    ?endNode:Node
  ) {
    var node = startNode;
    while (node != endNode) {
      var n = node.nextSibling;
      if (n == null) return;
      container.removeChild(n);
      node = n;
    }
  }

  public static function createMarker() {
    return Browser.document.createComment('');
  }

}
