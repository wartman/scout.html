import js.Browser;
import js.html.Event;
import scout.html.Renderer;
import scout.html.Template.html;
import component.Header;

class Test {

  public static function main() {
    var foo = (thing:String, ev:(e:Event)->Void) -> html(<>
      <Header title="foo" items=${['a', 'b', 'c']}>
        Bar
      </Header>
      <button onClick={ev}>Change</button>
      <div class="test">
        <p>Foo {thing}</p>
      </div>
    </>);
    Renderer.render(foo('Test', e -> {
      Renderer.render(foo('Ok!', e -> trace('ok!')), Browser.document.getElementById('root'));
    }), Browser.document.getElementById('root'));
  }

}