package scout.html.part;

import scout.html.Element;

using Reflect;

class PropertyCommitter extends AttributeCommitter {

  final single:Bool;
  final ref:Element;

  public function new(ref:Element, name:String, strings:Array<String>) {
    super(ref, name, strings);
    this.ref = ref;
    single = (strings.length == 2 && strings[0] == '' && strings[1] == '');
  }

  override function createPart() {
    return new PropertyPart(this);
  }

  override function prepare() {
    if (single) {
      return parts[0].value;
    }
    return super.prepare();
  }

  override function commit() {
    if (dirty) {
      dirty = false;
      ref.setProperty(name, prepare());
    }
  }

}
