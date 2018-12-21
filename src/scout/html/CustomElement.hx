package scout.html;

import js.html.Element;

@:autoBuild(scout.html.macro.CustomElementBuilder.build())
class CustomElement {

  public final el:Element;

  public function new(el:Element) {
    this.el = el;
    this.update();
  }

  // public function committed() {
  //   update();
  // }

  function update() {
    if (shouldRender()) {
      var result = render();
      if (result != null) {
        Renderer.render(result, el);
      }
    }
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render():Null<TemplateResult> {
    return null;
  }

}
