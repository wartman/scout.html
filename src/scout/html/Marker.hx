package scout.html;

import js.Browser;
import js.html.Node;

@:forward
abstract Marker(Node) from Node to Node {
  
  public inline function new() {
    this = Browser.document.createComment('');
  }

}
