package scout.html;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Context;
  import scout.html.dsl.*;

  using haxe.macro.PositionTools;
#end

#if js
  import js.html.Node;
  import scout.html.ElementType;

  using StringTools;
#end

class Template {
  
  public static macro function html(tpl:Expr) {
    return switch (tpl.expr) {
      case EConst(CString(s)) | EMeta({ name: ':markup' }, { expr: EConst(CString(s)) }):
        var info = tpl.pos.getInfos();
        try {
          var ast = new MarkupParser(s, info.file, info.min).parse();
          new DomGenerator(ast, tpl.pos).generate();
        } catch (e:DslError) {
          Context.error(e.message, Context.makePosition({
            min: e.pos.min,
            max: e.pos.max,
            file: info.file
          }));
          macro null;
        }
      default: Context.error('Expected a string', tpl.pos);
    }
  }

  #if !macro

    public static function render(type:ElementType, context:Context):Node {
      return switch type {
        case ENative(name, attrs, children):
          var el = Dom.createElement(name);
          handleAttributes(el, attrs, context);
          handleChildren(el, children, context);
          el;
        case EText(s):
          Dom.createTextNode(s);
        case EComponent(component):
          context.add(component);
          component._scout_target.getNode();
        case EFragment(children):
          new Fragment([
            for (c in children) render(c, context)
          ]);
        case EPart:
          var patcher = new Patcher();
          context.add(patcher);
          patcher.target.getNode();
      }
    }

    static function handleChildren(el:Element, children:Array<ElementType>, context:Context) {
      for (child in children) {
        if (child == null) continue;
        el.appendChild(render(child, context));
      }
    }

    static function handleAttributes(el:Element, attrs:Array<ElementAttribute>, context:Context) {
      for (attr in attrs) switch attr.value {
        case AttrConstant(value):
          handleAttribute(el, attr.name, ValueDynamic(value), ValueDynamic(null));
        case AttrPart:
          context.add(new Property(handleAttribute.bind(el, attr.name)));
      }
    }
    
    static function handleAttribute(el:Element, name:String, value:Value, previousValue:Value) {
      switch [ value, previousValue ] {
        case [ ValueDynamic(newValue), ValueDynamic(oldValue) ]:
          if (oldValue == newValue) return;
          if (name.startsWith('on')) {
            // todo: replace this with a `ValueEvent`.
            var event = name.substr(2).toLowerCase();
            el.removeEventListener(event, oldValue);
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

  #end

}
