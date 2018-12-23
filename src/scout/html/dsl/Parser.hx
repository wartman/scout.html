package scout.html.dsl;

import haxe.macro.Context;
import haxe.macro.Expr;
import scout.html.dsl.Node;

class Parser {

  public static function parse(expr:Expr):Node {
    return root(expr);
  }

  static function root(expr:Expr):Node {
    return parseNode(expr);
  }

  static function parseNode(expr:Expr):Node {
    switch (expr.expr) {

      case EMeta(m, e):
        var body:Array<Node> = [];

        for (e in m.params) switch (e.expr) {
          case EBinop(_, _, _): 
            body.push(parseNode(e));
          case EConst(CString(_)) | EConst(CIdent(_)):
            body.push(NodeId(e));
          default:
            Context.error('Only attribute assignments or strings of class/id names are allowed here', e.pos);
        }

        switch (e.expr) {
          case EBlock(exprs): for (e in exprs) switch (e.expr) {
            case _: body.push(parseNode(e));
          }
          case _: body.push(parseNode(e));
        }

        var tagName = { 
          value:m.name,
          pos: expr.pos
        };
        return NodeTag(tagName, isType(m.name) ? KindClass : KindTag, body);

      case EBinop(OpAssign, e1, e2): switch (e1.expr) {
        case EConst(CIdent(s)) | EConst(CString(s)):
          var name = { value: s, pos: e1.pos };
          return NodeAttribute(name, e2);
        case EField(e, field):
          var path:Array<String> = [ field ];
          while (e != null) switch (e.expr) {
            case EField(e2, field):
              path.unshift(field);
              e = e2;
            case EConst(CIdent(s)):
              path.unshift(s);
              e = null;
            default:
              Context.error('Invalid attribute', e.pos);
              e = null;
          }
          var name = { value: path.join('.'), pos: e1.pos };
          return NodeAttribute(name, e2);
        default:
          Context.error('Invalid attribute', e1.pos);
      }

      case EBlock(exprs):
        return NodeFragment(exprs.map(parseNode));

      case EArrayDecl(values): 
        return NodeFragment(values.map(parseNode));

      case EIf(econd, eif, eelse): 
        return NodeIf(econd, parseNode(eif), eelse != null ? parseNode(eelse) : null);

      case EFor(it, expr):
        var body = switch (expr.expr) {
          case EBlock(exprs) | EArrayDecl(exprs): NodeFragment(exprs.map(parseNode));
          case _: parseNode(expr);
        }
        return NodeFor(it, body);

      default: 
        return NodeValue(expr);

    }

    return NodeNone;
  }

  private static function isType(name:String) {
    var caps = ~/[A-Z]/;
    if (name.indexOf('.') >= 0) {
      name = name.split('.').pop();
    }
    return caps.match(name.charAt(0));
  }

}
