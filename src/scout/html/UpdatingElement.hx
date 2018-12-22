package scout.html;

import js.html.Element;
import haxe.ds.Map;
// import haxe.Timer;

@:autoBuild(scout.html.macro.PropertyBuilder.build())
@:noElement
class UpdatingElement extends CustomElement {

  // var timer:Timer;
  final properties:Map<String, Dynamic> = new Map();

  public function new(el:Element) {
    super(el);
    update();
  }

  // function requestUpdate() {
  //   if (timer != null) return;
  //   timer = Timer.delay(() -> {
  //     timer = null;
  //     update();
  //   }, 10);
  // }

  public function setProperty(name:String, value:Dynamic) {
    properties.set(name, value);
    update();
  }

  public function getProperty(name:String) {
    return properties.get(name);
  }

  public function update() {
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
