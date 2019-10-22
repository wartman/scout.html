package scout.html2;

#if js

import js.Browser;
import js.html.Node;

@:forward
abstract Fragment(Node) from Node to Node {
  
  public function new(items:Array<Element>) {
    this = Browser.document.createDocumentFragment();
    for (item in items) {
      if (item != null) this.appendChild(item);
    }
  }

}

#else

@:forward
abstract Fragment(String) from String to String {
  
  public function new(items:Array<Element>) {
    var out:Array<String> = [];
    for (item in items) {
      out.push(item);
    }
    this = out.join('');
  }

}

#end
