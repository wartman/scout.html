package scout.html.part;

import js.html.Element;

using scout.html.Dom;

class ClassAttributeCommitter extends AttributeCommitter {

  public function new(element:Element, strings:Array<String>) {
    super(element, '', strings);
  }

  override function commit() {
    if (dirty) {
      element.setElementIdentifiers(prepare());
    }
  }

}
