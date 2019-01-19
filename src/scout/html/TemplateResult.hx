package scout.html;

class TemplateResultImpl {

  public final factory:TemplateFactory;
  public final values:Array<Dynamic>;

  public function new(factory:TemplateFactory, values:Array<Dynamic>) {
    this.factory = factory;
    this.values = values;
  }

}

@:forward
abstract TemplateResult(TemplateResultImpl) {

  public function new(factory:TemplateFactory, values:Array<Dynamic>) {
    this = new TemplateResultImpl(factory, values);
  }

  @:from public static function ofComponent(component:Component) {
    return component._scout_render();
  }

  @:from public static function ofArray(children:Array<Dynamic>) {
    return new TemplateResult(new ValueTemplateFactory(), [ children ]);
  }

}
