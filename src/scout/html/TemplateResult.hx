package scout.html;

interface TemplateResultObject {
  public function getFactory():TemplateFactory;
  public function getValues():Array<Dynamic>;
}

class SimpleTemplateResult implements TemplateResultObject {

  final factory:TemplateFactory;
  final values:Array<Dynamic>;

  public function new(factory:TemplateFactory, values:Array<Dynamic>) {
    this.factory = factory;
    this.values = values;
  }

  public function getFactory() return factory;
  public function getValues() return values;

}

@:forward
abstract TemplateResult(TemplateResultObject) from TemplateResultObject {

  public function new(factory:TemplateFactory, values:Array<Dynamic>) {
    this = new SimpleTemplateResult(factory, values);
  }

  @:from public static function ofTemplateResultObj(res:TemplateResultObject) {
    return cast res;
  }

  @:from public static function ofArray(children:Array<Dynamic>) {
    return new TemplateResult(new ValueTemplateFactory(), [ children ]);
  }

}
