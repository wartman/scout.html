package scout.html.dom;

#if (js && !nodejs)

typedef DocumentFragment = js.html.DocumentFragment;

#else

class DocumentFragment extends Element {

  public function new() {
    super(DOCUMENT_FRAGMENT_NODE, '#document-fragment');
  }

}

#end
