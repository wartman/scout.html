package scout.html;

import scout.html.Dom.*;
import scout.html.dom.Node;

@:forward
abstract Target({
  startNode:Node,
  endNode:Node
}) {
  
  inline public function new() {
    this = {
      startNode: null,
      endNode: null
    };
  }

  inline public function insert(node:Node) {
    if (this.endNode.parentNode != null) {
      this.endNode.parentNode.insertBefore(node, this.endNode);
    }
  }

  inline public function appendInto(container:Node) {
    this.startNode = container.appendChild(createMarker());
    this.endNode = container.appendChild(createMarker());
  }

  inline public function insertAfterTarget(parent:Target) {
    parent.insert(this.startNode = createMarker());
    this.endNode = parent.endNode;
    parent.endNode = this.startNode;
  }

  inline public function appendIntoTarget(parent:Target) {
    parent.insert(this.startNode = createMarker());
    parent.insert(this.endNode = createMarker());
  }

}
