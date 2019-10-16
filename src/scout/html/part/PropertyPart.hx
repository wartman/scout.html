package scout.html.part;

class PropertyPart extends AttributePart {

  override function commit() {
    handleDirective();
    if (pendingValue != currentValue) {
      Reflect.setProperty(element, name, pendingValue);
    }
    currentValue = pendingValue;
  }

}
