package scout.html.part;

import js.html.Node;
import js.Browser;
import scout.html.Part;
import scout.html.Template;
import scout.html.TemplateResult;
import scout.html.Dom.*;

class NodePart implements Part {

  public var startNode:Node;
  public var endNode:Node;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;
  public var value(get, set):Dynamic;
  public function set_value(v:Dynamic) {
    pendingValue = v;
    return v;
  }
  public function get_value() return currentValue;

  public function new() {}
  
  public function insertAfterNode(ref:Node) {
    startNode = ref;
    endNode = ref.nextSibling;
  }

  public function appendInto(container:Node) {
    startNode = container.appendChild(createMarker());
    endNode = container.appendChild(createMarker());
  }

  public function appendIntoPart(part:NodePart) {
    part.insert(startNode = createMarker());
    part.insert(endNode = createMarker());
  }

  public function insertAfterPart(ref:NodePart) {
    ref.insert(startNode = createMarker());
    endNode = ref.endNode;
    ref.endNode = startNode;
  }

  public function insert(node:Node) {
    if (endNode.parentNode != null) {
      endNode.parentNode.insertBefore(node, endNode);
    }
  }

  public function commit() {
    var value:Dynamic = pendingValue;
    switch (Type.getClass(value)) {
      case TemplateResult: commitTemplateResult(value);
      case Node: commitNode(value);
      // ???? how get iterable
      case Array: commitIterable(value);
      default: if (value != currentValue) commitText(value);
    }
  }

  function commitIterable(value:Array<Dynamic>) {
    if (!Std.is(currentValue, Array)) {
      currentValue = [];
      clear();
    }
    var itemParts:Array<NodePart> = cast currentValue;
    var partIndex = 0;
    var itemPart:NodePart = null;
    for (item in value) {
      itemPart = itemParts[partIndex];
      if (itemPart == null) {
        itemPart = new NodePart();
        itemParts.push(itemPart);
        if (partIndex == 0) {
          itemPart.appendIntoPart(this);
        } else {
          itemPart.insertAfterPart(itemParts[partIndex - 1]);
        }
      }
      itemPart.value = item;
      itemPart.commit();
      partIndex++;
    }
    if (partIndex < itemParts.length) {
      itemParts = itemParts.splice(0, partIndex);
      clear(itemPart != null ? itemPart.endNode : null);
    }
  }

  function commitTemplateResult(value:TemplateResult) {
    var factory = value.factory;
    switch (Std.instance(currentValue, Template)) {
      case instance if (instance != null && instance.id == factory.id):
        currentValue.update(value.values);
      default:
        var template = value.factory.get();
        var fragment = template.el;
        template.update(value.values);
        commitNode(fragment);
        currentValue = template;
    }
  }

  function commitNode(value:Node):Void {
    if (this.value == value) return;
    clear();
    insert(value);
    currentValue = value;
  }

  function commitText(value:String) {
    var node = startNode.nextSibling;
    value = value == null ? '' : value;
    if (
      node == endNode.previousSibling
      && node.nodeType == Node.TEXT_NODE
    ) {
      node.textContent = value;
    } else {
      commitNode(Browser.document.createTextNode(value));
    }
    currentValue = value;
  }

  public function clear(?startNode:Node) {
    if (startNode == null) startNode = this.startNode;
    removeNodes(
      startNode.parentNode, 
      startNode.nextSibling,
      endNode
    );
  }

}
