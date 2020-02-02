Scout Html
==========

A first pass at porting (with some differences) [lit-html](https://github.com/Polymer/lit-html) into Haxe.

Templates
---------

Templates in Scout work about the same as they do in `lit-html`:

```haxe

// `scout.html.dom` provides a simple DOM shim in Sys environments
// or aliases for the real DOM in JS environments.
import scout.html.dom.Document;
import scout.html.Template.html;
import scout.html.Template.render;

class Main {

  public static function main() {
    var root = Document.root.body;
    var title = 'foo';
    var items = [ 'a', 'b', 'c' ];
    render(html(<div>
      <h1>${foo}</h1>
      <ul>
        ${ [ for (item in items) <li>${item}</li> ] }
      </ul>
    </div>), root);
  }

}

```

Components
----------

There are two ways to create components: either using `scout.html.Component` or with an abstract that casts to `scout.html.TemplateResult`. In general, you'll want to only use `scout.html.Component` if you need to deal with state -- as there is some overhead involved -- and use abstracts for everything else. Not that this is NOT the same as CustomElements.

Here's an example of a stateless component:

```haxe

import scout.html.*;

abstract Button(TemplateResult) to TemplateResult {

  public function new(props:{
    className:String,
    event:(e:js.html.Event)->Void,
    // Note: children is a special property that will take a
    //       node's children. It MUST be a `TemplateResult`
    children:TemplateResult
  }) {
    this = Template.html('<button 
      class={props.className}
      @click={props.onClick}
    >
      {props.children}
    </button>');
  }

}

```

Using a component (of either type) is simple -- the node name is just uppercase. We can see it in the below example:

```haxe

import scout.html.*;

class Example extends Component {

  @:attribute var title:String; 

  function setTitle(e) {
    title = 'foo'; // will automatically re-render the component
  }

  override function render():TemplateResult {
    // Note that you can use the `${var}` syntax as well.
    return Template.html('
      <p>${title}</p>
      <Button class="foo" event=${setTitle}>Click Me</Button>
    ');
  }

} 

```

...more to come...
