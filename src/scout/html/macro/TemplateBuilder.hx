#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import scout.html.dsl.*;

using haxe.macro.PositionTools;

class TemplateBuilder {

  public static function parse(tpl:ExprOf<String>) {
    return switch (tpl.expr) {
      case EConst(CString(s)):
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
#end