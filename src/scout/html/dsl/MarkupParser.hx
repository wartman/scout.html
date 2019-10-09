package scout.html.dsl;

using StringTools;

typedef MarkupPos = { min:Int, max:Int };

typedef Attribute = { name:String, value:AttributeValue, pos:MarkupPos };

enum AttributeValue {
  Raw(v:String);
  Code(v:String);
}

enum MarkupKind {
  Node(name:String);
  Text(value:String);
  CodeBlock(v:String);
  None;
}

typedef MarkupNode = {
  kind:MarkupKind,
  pos:MarkupPos,
  ?attributes:Array<Attribute>,
  ?children:Array<MarkupNode>
}

class MarkupParser extends Parser<Array<MarkupNode>> {

  override function parse():Array<MarkupNode> {
    var out:Array<MarkupNode> = [];
    while (!isAtEnd()) out.push(parseRoot());
    if (out.length == 0) {
      out.push({
        kind: None,
        pos: getPos(position, position)
      });
    }
    return out;
  }

  function parseRoot():MarkupNode {
    whitespace();
    var start = position;
    return switch advance() {
      case '<': parseNode();
      case '$': parseCodeBlock(0);
      case '{': parseCodeBlock(1);
      default: parseText(previous());
    }
  }

  function parseNode():MarkupNode {
    var start = position;
    var name = ident();
    var attrs:Array<Attribute> = [];
    whitespace();
    while (!(peek() == '>' || peek() == '/') && !isAtEnd()) {
      var attrStart = position;
      var key = ident();
      whitespace();
      consume('=');
      whitespace();
      var value = parseValue();
      whitespace();
      attrs.push({
        name: key,
        value: value,
        pos: getPos(attrStart, position)
      });
    }
    var children:Array<MarkupNode> = [];

    if (!match('/>')) {
      consume('>');
      whitespace();

      var didClose = false;
      var checkClose = () -> didClose = match('</${name}');

      if (!checkClose()) while (!isAtEnd()) {
        whitespace();
        if (checkClose()) break;
        children.push(parseRoot());
      }

      if (!didClose) {
        error('Unclosed tag: ${name}', start, position);
      }
    }

    return {
      kind: Node(name),
      attributes: attrs,
      pos: getPos(start, position),
      children: children
    };
  }

  function parseText(init:String):MarkupNode {
    var start = position;
    var out = init;
    while (
      !isAtEnd() 
      // todo: allow escapes
      && peek() != '<'
      && peek() != '$'
      && peek() != '{'
    ) {
      out += advance();
    }
    if (out.trim().length == 0) {
      return {
        kind: None,
        pos: getPos(start, position)
      }
    }
    return {
      kind: Text(out),
      pos: getPos(start, position)
    };
  }

  function parseCodeBlock(braces:Int):MarkupNode {
    var start = position;
    var out:String = parseCode(braces);
    return {
      kind: CodeBlock(out),
      pos: getPos(start, position)
    };
  }

  function parseValue():AttributeValue {
    return switch advance() {
      case '$': Code(parseCode(0));
      case '{': Code(parseCode(1));
      case '"': Raw(string('"'));
      case "'": Raw(string("'"));
      default: 
        if (peek() == '{') {
          Code(parseCode(0));
        } else {
          error('Expected a string, `$${...}` or `{...}`', position, position);
          null;
        }
    }
  }

  function string(delimiter:String) {
    var out = '';
    var start = position;
    while (!isAtEnd() && !match(delimiter)) {
      out += advance();
      if (previous() == '\\' && !isAtEnd()) {
        out += '\\${advance()}';
      }
    }
    if (isAtEnd()) error('Unterminated string', start, position);
    return out;
  }

  function parseCode(braces:Int):String {
    var out:String = '';
    if (match('{')) braces++;
    
    if (braces >= 1) {
      while (!isAtEnd() && braces != 0) {
        var add = advance();
        if (add == '{') braces++;
        if (add == '}') braces--;
        if (braces == 0) break;
        out += add;
      }
    } else {
      out = ident();
    }

    return out;
  }

  function ident() {
    return [ 
      while (isAlphaNumeric(peek()) && !isAtEnd()) advance() 
    ].join('');
  }

}
