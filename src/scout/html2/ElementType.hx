package scout.html2;

enum ElementAttributeValue {
  AttrConstant(s:String);
  AttrPart;
}

typedef ElementAttribute = {
  name:String,
  value:ElementAttributeValue
}

enum ElementType {
  ENative(
    name:String,
    attrs:Array<ElementAttribute>,
    children:Array<ElementType>
  );
  EText(s:String);
  EComponent(component:Component);
  EFragment(children:Array<ElementType>);
  EPart;
}
