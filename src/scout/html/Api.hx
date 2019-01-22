package scout.html;

class Api {

  public macro static function html(e:haxe.macro.Expr.ExprOf<String>) {
    return scout.html.macro.TemplateBuilder.parse(e);
  }

  #if !macro
    
    public static function render(result, container) {
      return Renderer.render(result, container);
    }

  #end

}
