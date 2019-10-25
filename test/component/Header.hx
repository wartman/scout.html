package component;

import scout.html.*;
import scout.html.Template.html;

class Header extends Component {

  @:attribute var title:String;
  @:attribute var items:Array<String> = [];
  var i:Int = 0;

  public function changeTitle(e) {
    title = 'Changed: ${i++}';
  }

  override function render():Result {
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

abstract Button(Result) to Result {
  
  public function new(props:{
    ev:(e:js.html.Event)->Void,
    children:Result
  }) {
    this = html('
      <button onClick={props.ev}>
        {props.children}
      </button>
    ');
  }

}
