package scout.html;

class Api {

  public macro static function html(e:haxe.macro.Expr.ExprOf<String>) {
    return scout.html.macro.TemplateBuilder.parse(e);
  }

  public macro static function build(e) {
    var node = scout.html.dsl.Parser.parse(e);
    return new scout.html.dsl.Generator(node).generate();
  }

  #if !macro
    public static function render(result, container) {
      return Renderer.render(result, container);
    }
  #end

}
