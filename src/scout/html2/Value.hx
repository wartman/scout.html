package scout.html2;

enum Value {
  ValueDynamic(s:Dynamic);
  ValueResult(r:Result);
  ValueIterable(values:Array<Value>);
}
