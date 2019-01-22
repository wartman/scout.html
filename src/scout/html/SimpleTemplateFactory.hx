package scout.html;

import js.html.Element;
import js.Browser;
import scout.html.part.NodePart;

class SimpleTemplateFactory implements TemplateFactory {

  static var _scout_ids:Int = 0;

  final id:String = "_scout_array_factory_" + _scout_ids++;

  public function new() {}

  public function getId() return id;

  public function getTemplate() {
    var el:Element = cast Browser.document.createDocumentFragment();
    var part = new NodePart();
    part.appendInto(el);
    return new Template(id, el, [ part ]);
  }

}
