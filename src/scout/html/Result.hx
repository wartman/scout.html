package scout.html;

class Result {
  
  public final factory:Factory;
  public final values:Array<Value>;

  public function new(factory, values) {
    this.factory = factory;
    this.values = values;
  }

}
