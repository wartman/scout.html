import js.html.InputElement;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;
import scout.html.UpdatingElement;

using scout.html.Renderer;

class Test {

  public static function main() {
    var header = (title, id, className) -> html('
      <header id="${id}" className="${className}">
        <h3>${title}</h3>
      </header>
    ');
    var input = (title:String, todos:Array<Todo>) -> html('
      ${header(title, 'MainHeader', 'header')}
      <todo-list .todos="${todos}" />
    ');
    input('Title', [
      new Todo('0', 'test', false)
    ]).render(Browser.document.getElementById('root'));
  }

}

class Todo {
  
  public var id:String;
  public var content:String;
  public var completed:Bool;
  public var editing:Bool = false;

  public function new(id, content, completed) {
    this.id = id;
    this.content = content;
    this.completed = completed;
  }

}

@:element('todo-input')
class TodoInput extends UpdatingElement {

  @:attr var className:String;
  @:prop var label:String;
  @:prop var value:String;
  @:prop var onSubmit:(value:String)->Void;

  function handleChange(e:Event) {
    var input:InputElement = cast e.target;
    properties.set('value', input.value);
  }

  function handleSubmit(e:Event) {
    e.preventDefault();
    onSubmit(value);
    value = '';
    update();
  }

  override function render() return html('
    <input 
      class="${className}"
      value="${value}"
      on:change="${handleChange}"
    />
    <button 
      class="create"
      on:click="${handleSubmit}"
    >${label}</button>
  ');

}

@:element('todo-item', { extend: 'li' })
class TodoItem extends UpdatingElement {

  @:prop var todo:Todo;

  public function removeItem() {
    remove();
  }

  function toggleComplete(e:Event) {
    todo.completed = !todo.completed;
    update();
  }

  function updateContent(value:String) {
    todo.content = value;
    todo.editing = false;
    update();
  }

  function toggleEditing() {
    todo.editing = true;
    update();
  }

  override function shouldRender() {
    return todo != null;
  }

  // Something is wrong with the NodePart, I think, as it
  // doesn't properally remove an old Node (at least with
  // TemplateResults). Sure do need tests :V
  override function render() return html('
    ${if (todo.editing) html('
      <todo-input
        className="edit"
        .label="update"
        .value="${todo.content}"
        .onSubmit="${updateContent}" 
      />
    ') else html ('
      <input 
        class="toggle" 
        type="checkbox" 
        on:change="${toggleComplete}"
        is:checked="${todo.completed}" 
      />
      <label>${todo.content}</label>
      <button class="edit" on:click="${_ -> toggleEditing()}">Edit</button>
      <button class="destroy" on:click="${_ -> removeItem()}">Remove</button>
    ')}
  ');

}

@:element('todo-list')
class TodoList extends UpdatingElement {

  @:prop var todos:Array<Todo>;
  var initValue:String = '';

  function makeTodo(value:String) {
    todos.push(new Todo(
      Std.string(todos.length + 1),
      value,
      false
    ));
    update();
  }

  override function shouldRender() {
    return todos != null;
  }

  override function render() return html('
    <todo-input .label="create" .value="${initValue}" .onSubmit="${makeTodo}" />
    <ul class="todo-list">
      ${[ for (todo in todos) html('<todo-item .todo="${todo}" />') ]}
    </ul>
  ');

}