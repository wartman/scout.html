import js.html.InputElement;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;
import scout.element.ScoutElement;

import todo.model.Todo;
import todo.view.TodoItem;
import todo.view.TodoList;

using scout.html.Renderer;

class Test {

  public static function main() {
    var header = (title) -> html('
      <header>
        <h3>${title}</h3>
      </header>
    ');
    var input = (
      todos:Array<Todo>,
      initialValue:String, 
      handleClick:(e:Event)->Void
    ) -> html('
      ${header('Test')}
      <div id="display"></div>
      <input id="target" class="test" name="foo" value="${initialValue}" />
      <button on:click="${handleClick}">Change</button>
      <todo-list .todos="${todos}"></todo-list>
    ');
    input([
      new Todo('0', 'stuff', true),
      new Todo('1', 'other stuff', false)
    ], 'foo', e -> {
      var value:InputElement = cast Browser.document.getElementById('target');
      showFoo(value.value);
    }).render(Browser.document.getElementById('root'));
  }

  static function showFoo(value:String) {
    html('<p>${value}</p>')
      .render(Browser.document.getElementById('display'));
  }

}
