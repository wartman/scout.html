import js.html.InputElement;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;
import scout.html.CustomElement;

using scout.html.Renderer;

class Test {

  public static function main() {
    var header = (title, id, className) -> html('
      <header id="${id}" className="${className}">
        <h3>${title}</h3>
      </header>
    ');
    var input = (title:String) -> html('
      ${header(title, 'MainHeader', 'header')}
      <test-el .location="world" />
      <test-el class="test" .location="mars" />
    ');
    input('Title').render(Browser.document.getElementById('root'));
  }

}

@:element('test-el', { extend: 'section' })
class TestEl extends CustomElement {

  public var location:String;

  function updateLocation(e:Event) {
    var input:js.html.InputElement = cast e.target;
    location = input.value;
  }

  override function render() return html('
    <input value="" on:change="${updateLocation}" />
    <button on:click="${_ -> update()}">Set Location</button>
    <p>Hey ${location}!</p>
  ');

}
