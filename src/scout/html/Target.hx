package scout.html;

import js.html.Node;

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

  inline public function getNode() {
    return new Fragment([
      this.startNode = new Marker(),
      this.endNode = new Marker()
    ]);
  }

  inline public function insert(node:Node) {
    if (this.endNode.parentNode != null) {
      this.endNode.parentNode.insertBefore(node, this.endNode);
    }
  }

  inline public function appendInto(container:Node) {
    this.startNode = container.appendChild(new Marker());
    this.endNode = container.appendChild(new Marker());
  }

  inline public function insertAfterTarget(parent:Target) {
    parent.insert(this.startNode = new Marker());
    this.endNode = parent.endNode;
    parent.endNode = this.startNode;
  }

  inline public function appendIntoTarget(parent:Target) {
    parent.insert(this.startNode = new Marker());
    parent.insert(this.endNode = new Marker());
  }

}
