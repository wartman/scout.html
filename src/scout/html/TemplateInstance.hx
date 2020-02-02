package scout.html;

import scout.html.dom.Element;

class TemplateInstance {

  public final id:String;
  public final parts:Array<Null<Part>>;  
  public final el:Element;

  public function new(
    id:String,
    el:Element,
    parts:Array<Null<Part>>
  ) {
    this.id = id;
    this.el = el;
    this.parts = parts;
  }

  public function update(values:Array<Dynamic>) {
    for (i in 0...parts.length) {
      if (i > values.length) break;
      parts[i].setValue(values[i]);
    }
    for (part in parts) {
      part.commit();
    }
  }

}
