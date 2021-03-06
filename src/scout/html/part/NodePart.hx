package scout.html.part;

import scout.html.*;
import scout.html.DomTools.*;
import js.html.*;

class NodePart implements Part {

  public final __target:Target = new Target();
  var pendingValue:Dynamic;
  var currentValue:Dynamic;

  public function new() {}
  
  public function setValue(v:Dynamic) {
    pendingValue = v;
  }

  public function commit() {
    while (Std.is(pendingValue, Directive)) {
      var directive:Directive = pendingValue;
      pendingValue = null;
      directive.handle(this);
    }
    
    var value:Dynamic = pendingValue;
    switch (Type.getClass(value)) {
      case TemplateResult: commitTemplateResult(value);
      case Node: commitNode(value);
      // ???? how get iterable
      case Array: commitIterable(value);
      default: 
        if (value == null) return;
        if (value != currentValue) commitText(value);
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
          itemPart.__target.appendIntoTarget(__target);
        } else {
          itemPart.__target.insertAfterTarget(itemParts[partIndex - 1].__target);
        }
      }
      itemPart.setValue(item);
      itemPart.commit();
      partIndex++;
    }
    if (partIndex < itemParts.length) {
      itemParts = itemParts.splice(0, partIndex);
      clear(itemPart != null ? itemPart.__target.endNode : null);
    }
  }

  function commitTemplateResult(value:TemplateResult) {
    var factory = value.factory;
    switch (Std.downcast(currentValue, TemplateInstance)) {
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
    if (currentValue == value) return;
    clear();
    __target.insert(value);
    currentValue = value;
  }

  function commitText(value:String) {
    var node = __target.startNode.nextSibling;
    value = value == null ? '' : value;
    if (
      node == __target.endNode.previousSibling
      && node.nodeType == Node.TEXT_NODE
    ) {
      var txt:Text = cast node;
      txt.textContent = value;
    } else {
      commitNode(js.Browser.document.createTextNode(value));
    }
    currentValue = value;
  }

  public function clear(?startNode:Node) {
    if (startNode == null) startNode = __target.startNode;
    removeNodes(
      startNode.parentNode, 
      startNode.nextSibling,
      __target.endNode
    );
  }


}