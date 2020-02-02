package component;

import scout.html.dom.Event;
import scout.html.Component;
import scout.html.TemplateResult;
import scout.html.Template.html;

class Header extends Component {

  @:attribute var title:String;
  @:attribute var items:Array<String> = [];
  var i:Int = 0;

  public function changeTitle(e) {
    title = 'Changed: ${i++}';
  }

  override function render():TemplateResult {
    return html(
      <header>
        <p>{title}</p>
        <Button ev={changeTitle}>Change!</Button>
        <component.Button ev={e -> {
          i = 0;
          title = "Reset";
        }}>Reset</component.Button>
        <for {item in items}>
          <p>{item}</p>
        </for>
        <if {children != null}>
          {children}
        <else>
          No children.
        </if>
      </header>
    );
  }

}

abstract Button(TemplateResult) to TemplateResult {
  
  public function new(props:{
    ev:(e:Event)->Void,
    children:TemplateResult
  }) {
    this = html('
      <button onClick={props.ev}>
        {props.children}
      </button>
    ');
  }

}
