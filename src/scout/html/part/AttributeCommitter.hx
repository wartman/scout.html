package scout.html.part;

import js.html.Element;

class AttributeCommitter {

  final element:Element;
  final name:String;
  final strings:Array<String>;
  public final parts:Array<AttributePart> = [];
  public var dirty:Bool = true;

  public function new(element:Element, name:String, strings:Array<String>) {
    this.element = element;
    this.name = name;
    this.strings = strings;
    var len = strings.length - 1;
    for (i in 0...len) {
      parts[i] = createPart();
    }
  }

  public function commit() {
    if (dirty) {
      dirty = false;
      element.setAttribute(name, prepare());
    }
  }

  function createPart() {
    return new AttributePart(this);
  }

  function prepare() {
    var text = '';
    var end = strings.length - 1;
    for (i in 0...end) {
      var str = strings[i];
      text += str;
      var part = parts[i];
      if (part != null) {
        var value = part.value;
        if (
          value != null
          && Std.is(value, Array)
        ) {
          var iter:Array<Dynamic> = cast value;
          for (t in iter) {
            text += t;
          }
        } else {
          text += value;
        }
      }
    }
    return text + strings[end];
  }

}
