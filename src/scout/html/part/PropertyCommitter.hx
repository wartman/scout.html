package scout.html.part;

import js.html.Element;

using Reflect;

class PropertyCommitter extends AttributeCommitter {

  final single:Bool;

  public function new(element:Element, name:String, strings:Array<String>) {
    super(element, name, strings);
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
      var obj:Dynamic = cast element;
      obj.setField(name, prepare());
    }
  }

}
