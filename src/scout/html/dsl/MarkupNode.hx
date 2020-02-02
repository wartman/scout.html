package scout.html.dsl;

typedef MarkupPosition = { 
  min:Int,
  max:Int 
}

typedef MarkupAttribute = { 
  name:String,
  value:MarkupAttributeValue, 
  pos:MarkupPosition 
}

enum MarkupAttributeValue {
  Raw(value:String);
  Code(value:String);
}

enum MarkupNodeDef {
  MNode(
    name:String,
    attrs:Array<MarkupAttribute>,
    children:Array<MarkupNode>,
    isComponent:Bool
  );
  MFragment(children:Array<MarkupNode>);
  MText(value:String);
  MCode(value:String);
  MNone;
}

typedef MarkupNode = {
  node:MarkupNodeDef,
  pos:MarkupPosition
}
