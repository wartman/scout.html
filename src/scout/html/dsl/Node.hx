package scout.html.dsl;

import haxe.macro.Expr;

typedef Located<T> = {
  public var pos(default, null):Position;
  public var value(default, null):T;
}

enum NodeKind {
  KindClass;
  KindTag;
}

enum Node {
  NodeNone;
  NodeValue(e:Expr);
  NodeId(e:Expr);
  NodeAttribute(name:Located<String>, value:Expr);
  NodeTag(name:Located<String>, kind:NodeKind, body:Array<Node>);
  NodeIf(cond:Expr, pass:Node, ?fail:Node);
  NodeFor(cond:Expr, body:Node);
  NodeFragment(body:Array<Node>);
}
