package scout.html;

class StaticTemplateFactory implements TemplateFactory {

  public final id:String;
  final factory:TemplateFactory;
  var template:Template;

  public function new(factory:TemplateFactory) {
    id = factory.id;
    this.factory = factory;
  }

  public function get() {
    if (template == null) template = factory.get();
    return template;
  }

}
