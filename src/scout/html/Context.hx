package scout.html;

import js.html.Node;

class Context {
  
  public final el:Node;
  public final id:String;
  final parts:Array<Part> = [];

  public function new(id, type:ElementType) {
    this.id = id;
    this.el = Template.render(type, this);
  }

  public function add(part:Part) {
    parts.push(part);
  }

  public function update(values:Array<Value>) {
    for (i in 0...parts.length) {
      if (i > values.length) break;
      parts[i].set(values[i]);
    }
    for (part in parts) {
      part.commit();
    }
  }
  
}
