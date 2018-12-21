package scout.html;

import js.Browser;
import js.html.Node;

class Dom {

  static var customElements:Array<{
    name:String, 
    get:()->CustomElement
  }>;
  
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

  // This is a weird little workaround for custom elements
  // until Haxe can handle real ones.

  // TODO: `extend` should be `extends`
  static public function registerElement(name:String, el:Class<CustomElement>, ?options:{ extend:String }) {
    if (options == null) { 
      options = { extend: 'div' };
    }
    if (customElements == null) {
      customElements = [];
    }
    customElements.push({
      name: name, 
      get: () -> Type.createInstance(el, [ Browser.document.createElement(options.extend) ])
    });
  }

  public static function createElement(name:String):ElementRef {
    if (customElements == null) {
      customElements = [];
    }
    for (ce in customElements) {
      if (ce.name == name) return ce.get();
    }
    return Browser.document.createElement(name);
  }

}
