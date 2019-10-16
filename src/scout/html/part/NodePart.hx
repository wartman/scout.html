package scout.html.part;

import js.html.Node;
import js.Browser;
import scout.html.*;
import scout.html.Dom.*;

class NodePart implements Part {

  public final _scout_target:Target = new Target();
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
          itemPart._scout_target.appendIntoTarget(_scout_target);
        } else {
          itemPart._scout_target.insertAfterTarget(itemParts[partIndex - 1]._scout_target);
        }
      }
      itemPart.setValue(item);
      itemPart.commit();
      partIndex++;
    }
    if (partIndex < itemParts.length) {
      itemParts = itemParts.splice(0, partIndex);
      clear(itemPart != null ? itemPart._scout_target.endNode : null);
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
    _scout_target.insert(value);
    currentValue = value;
  }

  function commitText(value:String) {
    var node = _scout_target.startNode.nextSibling;
    value = value == null ? '' : value;
    if (
      node == _scout_target.endNode.previousSibling
      && node.nodeType == Node.TEXT_NODE
    ) {
      node.textContent = value;
    } else {
      commitNode(Browser.document.createTextNode(value));
    }
    currentValue = value;
  }

  public function clear(?startNode:Node) {
    if (startNode == null) startNode = _scout_target.startNode;
    removeNodes(
      startNode.parentNode, 
      startNode.nextSibling,
      _scout_target.endNode
    );
  }


}