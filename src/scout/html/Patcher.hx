package scout.html;

import js.html.Node;
import js.Browser;

class Patcher implements Part {
  
  public final target:Target = new Target();
  var children:Array<Patcher> = [];
  var context:Context = null;
  var pendingValue:Value;
  var currentValue:Value = ValueDynamic(null);

  public function new() {}

  public function set(value:Value) {
    pendingValue = value;
  }
  
  public function commit() {
    if (pendingValue != currentValue) switch pendingValue {

      case ValueDynamic(s): switch currentValue {
        case ValueDynamic(old) if (s == old):
          // noop
        default:
          commitText(s);
      }

      case ValueIterable(values): switch currentValue {
        case ValueIterable(_):
          commitIterable(values);
        default:
          children = [];
          clear();
          commitIterable(values);
      }

      case ValueResult(newResult): switch currentValue {
        case ValueResult(oldResult) if (
          context != null 
          && context.id == oldResult.factory.id
        ):
          context.update(newResult.values);
        default:
          context = newResult.factory.get();
          var el = context.el;
          context.update(newResult.values);
          commitNode(el);
        }

    }
    currentValue = pendingValue;
  }

  public function dispose() {
    context = null;
    for (patcher in children) {
      patcher.dispose();
    }
    children.resize(0);
  }

  function commitIterable(values:Array<Value>) {
    var index = 0;
    var patcher:Patcher = null;
    for (value in values) {
      patcher = children[index];
      if (patcher == null) {
        patcher = new Patcher();
        children.push(patcher);
        if (index == 0) {
          patcher.target.appendIntoTarget(target);
        } else {
          patcher.target.insertAfterTarget(children[index - 1].target);
        }
      }
      patcher.set(value);
      patcher.commit();
      index++;
    }
    if (index < children.length) {
      children = children.splice(0, index);
      clear(patcher != null ? patcher.target.endNode : null);
    }
  }

  function commitText(value:String) {
    var node = target.startNode.nextSibling;
    value = value == null ? '' : value;
    if (
      node == target.endNode.previousSibling
      && node.nodeType == Node.TEXT_NODE
    ) {
      node.textContent = value;
    } else {
      commitNode(Browser.document.createTextNode(value));
    }
  }

  function commitNode(value:Node):Void {
    clear();
    target.insert(value);
  }

  function clear(?startNode:Node) {
    if (startNode == null) startNode = target.startNode;
    Dom.removeNodes(
      startNode.parentNode, 
      startNode.nextSibling,
      target.endNode
    );
  }

}
