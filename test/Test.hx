import scout.html.dom.*;
import scout.html.Component;
import scout.html.Template.html;
import scout.html.TemplateResult;
import component.Header;

using scout.html.Renderer;

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

    #if (php || nodejs)
    var root = Document.root.createElement('div');
    root.setAttribute('id', 'root');
    #else
    var root = Document.root.getElementById('root');
    #end

    Renderer.render(foo('Test', e -> {
      Renderer.render(foo('Ok!', e -> trace('ok!')), root);
    }), root);

    #if (php || nodejs)
    Sys.print(root.toString());
    #end
  }

}