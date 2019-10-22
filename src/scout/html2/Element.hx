package scout.html2;

#if js

import js.html.Node;
import scout.html2.ElementType;

using StringTools;

@:forward
abstract Element(Node) from Node to Node {
  
  public function new(type:ElementType, context:Context) {
    switch type {
      case ENative(name, attrs, children):
        this = Dom.createElement(name);
        handleAttributes(attrs, context);
        handleChildren(children, context);
      case EText(s):
        this = Dom.createTextNode(s);
      case EComponent(component):
        context.add(component);
        this = component._scout_target.getNode();
      case EFragment(children):
        this = new Fragment([
          for (c in children) new Element(c, context)
        ]);
      case EPart:
        var patcher = new Patcher();
        context.add(patcher);
        this = patcher.target.getNode();
    }
  }

  function handleChildren(children:Array<ElementType>, context:Context) {
    for (child in children) {
      if (child == null) continue;
      this.appendChild(new Element(child, context));
    }
  }

  function handleAttributes(attrs:Array<ElementAttribute>, context:Context) {
    for (attr in attrs) switch attr.value {
      case AttrConstant(value):
        handleAttribute(attr.name, ValueDynamic(value), null);
      case AttrPart:
        context.add(new Property(handleAttribute.bind(attr.name)));
    }
  }
  
  function handleAttribute(name:String, value:Value, previousValue:Value) {
    if (previousValue == null) {
      previousValue = ValueDynamic(null);
    }
    var el:js.html.Element = cast this;
    switch [ value, previousValue ] {
      case [ ValueDynamic(newValue), ValueDynamic(oldValue) ]:
        if (oldValue == newValue) return;
        if (name.startsWith('on')) {
          var event = name.substr(2).toLowerCase();
          el.removeEventListener(event, cast previousValue);
          el.addEventListener(event, newValue);
        } else if (newValue == true) {
          el.setAttribute(name, name);
        } else if (newValue == false || newValue == null) {
          el.removeAttribute(name);
        } else {
          el.setAttribute(name, newValue);
        }
      default:
        throw 'Invalid value';
    }
  }

}

#else

abstract Element(String) to String {

}

#end
