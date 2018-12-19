package scout.html;

class TemplateResult {

  public final factory:TemplateFactory;
  public final values:Array<Dynamic>;

  public function new(factory:TemplateFactory, values:Array<Dynamic>) {
    this.factory = factory;
    this.values = values;
  }

}
