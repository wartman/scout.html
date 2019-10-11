import js.Browser;
import js.html.Event;
import scout.html.Directive;
import scout.html.Part;
import scout.html.Template.html;
import scout.html.TemplateResult;

using scout.html.Renderer;

class Test {

  public static function main() {
    var foo = (thing:String, ev:(e:Event)->Void) -> html('
      ${new Header('foo')}
      <button onClick={ev}>Change</button>
      <div class="test">
        <p>Foo {thing}</p>
      </div>
    ');
    Renderer.render(foo('Test', e -> {
      Renderer.render(foo('Ok!', e -> trace('ok!')), Browser.document.getElementById('root'));
    }), Browser.document.getElementById('root'));
  }

}

abstract Button(TemplateResult) to TemplateResult {
  
  public function new(props:{
    ev:(e:js.html.Event)->Void,
    label:String
  }) {
    this = html('<button onClick={props.ev}>{props.label}</button>');
  }

}

class Component implements Directive {

  var _part:Part;

  public function render() {
    return html('');
  }

  public function update() {
    if (_part != null) {
      _part.value = render();
      _part.commit();
    }
  }

  public function handle(part:Part) {
    _part = part;
    part.value = render();
  }

}

class Header extends Component {

  var title:String;
  var i:Int = 0;

  public function new(title:String) {
    this.title = title;
  }

  public function changeTitle(e) {
    title = 'Changed' + i++;
    trace(title);
    update();
  }

  override function render():TemplateResult {
    return html('
      <header>
        <p>${title}</p>
        ${ new Button({ ev: changeTitle, label: 'Change!' }) }
      </header>
    ');
  }

}
