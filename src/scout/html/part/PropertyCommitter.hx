package scout.html.part;

import scout.html.ElementRef;

class PropertyCommitter extends AttributeCommitter {

  final single:Bool;
  final ref:ElementRef;

  public function new(ref:ElementRef, name:String, strings:Array<String>) {
    super(ref, name, strings);
    this.ref = ref;
    single = (strings.length == 2 && strings[0] == '' && strings[1] == '');
    if (parts.length == 0) {
      // For cases where we have a single value.
      parts.push(createPart());
    }
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
