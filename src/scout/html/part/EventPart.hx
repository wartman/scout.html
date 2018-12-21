package scout.html.part;

import js.html.Element;
import js.html.Event;
import scout.html.Part;
import scout.html.ElementRef;

class EventPart implements Part {

  final element:Element;
  final event:String;
  var boundEvent:(event:Event)->Void;
  var pendingValue:Dynamic;
  var currentValue:Dynamic;
  public var value(get, set):Dynamic;
  public function set_value(value:Dynamic) {
    pendingValue = value;
    return value;
  }
  public function get_value() return currentValue;

  public function new(element:ElementRef, event:String) {
    this.element = element;
    this.event = event;
    boundEvent = e -> handleEvent(e);
  }

  public function commit() {
    if (pendingValue == null) return;
    // // todo: like this
    // const newListener = this._pendingValue;
    // const oldListener = this.value;
    // const shouldRemoveListener = newListener == null ||
    //     oldListener != null &&
    //         (newListener.capture !== oldListener.capture ||
    //          newListener.once !== oldListener.once ||
    //          newListener.passive !== oldListener.passive);
    // const shouldAddListener =
    //     newListener != null && (oldListener == null || shouldRemoveListener);

    // if (shouldRemoveListener) {
    //   this.element.removeEventListener(
    //       this.eventName, this._boundHandleEvent, this._options);
    // }
    // if (shouldAddListener) {
    //   this._options = getOptions(newListener);
    //   this.element.addEventListener(
    //       this.eventName, this._boundHandleEvent, this._options);
    // }
    // this.value = newListener;
    // this._pendingValue = noChange;
    currentValue = pendingValue;
    element.removeEventListener(event, boundEvent);
    element.addEventListener(event, boundEvent);
    pendingValue = null;
  }

  function handleEvent(e:Event) {
    if (value == null) return;
    var ev:(e:Event)->Void = cast value;
    ev(e);
  }

}
