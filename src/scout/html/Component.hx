package scout.html;

import haxe.DynamicAccess;

@:autoBuild(scout.html.macro.ComponentBuilder.build())
class Component implements Part {
  
  @:noCompletion public final __target:Target = new Target();
  @:noCompletion var __properties:DynamicAccess<Dynamic> = {};
  @:noCompletion var __instance:TemplateInstance;

  final public function new() {
    __init();
  }
  
  public function setValue(props:Dynamic) {
    __properties = props;
  }

  @:noCompletion function __setProperty(key:String, value:Dynamic) {
    __properties.set(key, value);
    commit();
  }

  @:noCompletion function __getProperty(key:String):Dynamic {
    return __properties.get(key);
  }

  @:noCompletion function __init() {
    // noop;
  }

  public function commit() {
    if (__properties == null) {
      dispose();
    } else if (__instance != null) {
      __instance.update(render().values);
    } else {
      var result = render();
      __instance = result.factory.get();
      __instance.update(result.values);
      __target.insert(__instance.el);
    }
  }
  
  public function render():TemplateResult {
    return null;
  }

  public function dispose():Void {
    __instance = null;
    __properties = null;
  }

}
