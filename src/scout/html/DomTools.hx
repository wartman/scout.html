package scout.html;

import scout.html.dom.*;

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
    return Document.root.createComment('');
  }

  public static inline function createElement(name:String) {
    return Document.root.createElement(name);
  }

  public static inline function createTextNode(value:String) {
    return Document.root.createTextNode(value);
  }

}
