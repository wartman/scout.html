#if macro
package scout.html.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

class CustomElementBuilder {

  public static function build() {
    var cls = Context.getLocalClass().get();
    var path = cls.pack.concat([ cls.name ]);
    var fields = Context.getBuildFields();
    var meta = cls.meta.get();
    var el = meta.find(m -> m.name == ':element');
    if (el == null || el.params.length == 0) {
      if (meta.exists(m -> m.name == ':noElement')) {
        return fields;
      }
      Context.error('`@:element` declaration is required. To opt out of registering a custom element, use `@:noElement` meta.', cls.pos);
    }
    var build = el.params.length == 1 
      ? macro scout.html.Dom.registerElement(${el.params[0]}, $p{path})
      : macro scout.html.Dom.registerElement(${el.params[0]}, $p{path}, ${el.params[1]});

    fields = fields.concat((macro class {
      
      override public static function get_elementName() {
        return ${el.params[0]};
      }

      public static function __init__() {
        ${build};
      }
      
    }).fields);

    return fields;
  }

}
#end
