import js.html.InputElement;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;

using scout.html.Renderer;

class Test {

  public static function main() {
    var header = (title) -> html('
      <header>
        <h3>${title}</h3>
      </header>
    ');
    var input = (
      initialValue:String, 
      handleClick:(e:Event)->Void
    ) -> html('
      ${header('Test')}
      <div id="display"></div>
      <input id="target" class="test" name="foo" value="${initialValue}" />
      <button on:click="${handleClick}">Change</button>
    ');
    input('foo', e -> {
      var value:InputElement = cast Browser.document.getElementById('target');
      showFoo(value.value);
    }).render(Browser.document.getElementById('root'));
  }

  static function showFoo(value:String) {
    html('<p>${value}</p>')
      .render(Browser.document.getElementById('display'));
  }

}
