package scout.html;

interface Renderable {
  public function shouldRender():Bool;
  public function render():Null<TemplateResult>;
}
