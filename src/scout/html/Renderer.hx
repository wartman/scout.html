package scout.html;

import js.html.Node;
import js.html.Element;
import haxe.ds.Map;
import scout.html.part.NodePart;

class Renderer {
  
  static final parts = new Map<Node, NodePart>();

  public static function render(
    result:TemplateResult, 
    container:Element
  ) {
    var part = parts.get(container);
    if (part == null) {
      Dom.removeNodes(container, container.firstChild);
      part = new NodePart();
      parts.set(container, part);
      part.appendInto(container);
    }
    part.value = result;
    part.commit();
  }

  public static function renderComponent(result:Component, container:Element) {
    return render(result, container);
  }

}
