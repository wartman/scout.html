package scout.html.part;

class PropertyPart extends AttributePart {

  override function commit() {
    handleDirective();
    if (dirty) {
      dirty = false;
      Reflect.setProperty(element, name, value);
    }
  }

}
