Scout Html
==========

A first pass at creating a [lit-html](https://github.com/Polymer/lit-html) like
framework for Haxe.

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
      onClick={props.onClick}
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
