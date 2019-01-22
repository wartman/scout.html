package scout.html.part;

import js.html.Node;
import js.Browser;
import scout.html.Part;
import scout.html.Template;
import scout.html.TemplateResult;
import scout.html.TemplateUpdater;
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
    if (Std.is(value, TemplateResultObject)) {
      commitTemplateResult(value);
    } else if (Std.is(value, Node)) {
      commitNode(value);
    } else if (Std.is(value, Array) || Reflect.hasField(value, 'iterator')) {
      commitIterable(value);
    } else if (value != currentValue) { 
      commitText(value);
    }
  }

  function commitIterable(value:Iterable<Dynamic>) {
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
      for (i in partIndex...itemParts.length) {
        itemParts.remove(itemParts[i]);
      }
      if (itemPart == null) {
        clear();
      } else {
        clear(itemPart.endNode);
      }
    }

    value = itemParts;
  }

  function commitTemplateResult(value:TemplateResult) {
    var factory = value.getFactory();
    
    switch (Std.instance(currentValue, Template)) {
      case instance if (instance != null && instance.id == factory.getId()):
        currentValue.update(value.getValues());
      default:
        var template = factory.getTemplate();
        var fragment = template.el;
        template.update(value.getValues());
        commitNode(fragment);
        currentValue = template;
    }

    // Note: this is done here to ensure that the
    //       TemplateUpdater always has the correct
    //       template. This gets tricky when dealing
    //       with an array of TemplateResults.
    if (Std.is(value, TemplateUpdater)) {
      var com:TemplateUpdater = cast value;
      com.setTemplate(currentValue);
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
