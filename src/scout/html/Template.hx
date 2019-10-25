package scout.html;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;
  import scout.html.dsl.*;

  using haxe.macro.PositionTools;
#end

class Template {
  
  public static macro function html(tpl:Expr) {
    return switch (tpl.expr) {
      case EConst(CString(s)) | EMeta({ name: ':markup' }, { expr: EConst(CString(s)) }):
        var info = tpl.pos.getInfos();
        try {
          var ast = new MarkupParser(s, info.file, info.min).parse();
          new DomGenerator(ast, tpl.pos).generate();
        } catch (e:DslError) {
          Context.error(e.message, Context.makePosition({
            min: e.pos.min,
            max: e.pos.max,
            file: info.file
          }));
          macro null;
        }
      default: Context.error('Expected a string', tpl.pos);
    }
  }

}
