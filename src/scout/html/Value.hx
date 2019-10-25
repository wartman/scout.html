package scout.html;

enum Value {
  ValueDynamic(s:Dynamic);
  ValueResult(r:Result);
  ValueIterable(values:Array<Value>);
}
