package scout.html.dom;

#if (js && !nodejs)

typedef Comment = js.html.Comment;

#else

using StringTools;

class Comment extends Node {

  public var nodeValue:String;
  
  public function new(content:String = "") {
    super(COMMENT_NODE, '#comment');
    nodeValue = content;
  }

  override function toString() {
    return '<!-- ${nodeValue.htmlEscape()} -->';
  }

}

#end