package scout.html;

import haxe.ds.Map;
import scout.html.dom.*;
import scout.html.part.NodePart;

class Renderer {
  
  static final parts = new Map<Node, NodePart>();

  public static function render(
    result:TemplateResult, 
    container:Element
  ) {
    var part = parts.get(container);
    if (part == null) {
      DomTools.removeNodes(container, container.firstChild);
      part = new NodePart();
      parts.set(container, part);
      part._scout_target.appendInto(container);
    }
    part.setValue(result);
    part.commit();
  }

}
