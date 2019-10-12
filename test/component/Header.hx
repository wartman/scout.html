package component;

import scout.html.Component;
import scout.html.TemplateResult;
import scout.html.Template.html;

class Header extends Component {

  @:attribute var title:String;
  var i:Int = 0;

  public function changeTitle(e) {
    title = 'Changed: ${i++}';
  }

  override function render():TemplateResult {
    return html('
      <header>
        <p>${title}</p>
        <Button ev=${changeTitle}>Change!</Button>
        <Button ev=${e -> {
          i = 0;
          title = 'Reset';
        }}>Reset</Button>
        ${children}
      </header>
    ');
  }

}

// Note how abstracts can also be used as stateless 
// components!
abstract Button(TemplateResult) to TemplateResult {
  
  public function new(props:{
    ev:(e:js.html.Event)->Void,
    children:TemplateResult
  }) {
    this = html('
      <button onClick={props.ev}>
        {props.children}
      </button>
    ');
  }

}
