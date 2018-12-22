import js.html.InputElement;
import js.html.Element;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;
import scout.html.CustomElement;
import scout.html.TemplateResult;

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

@:noElement
class UpdatingElement extends CustomElement {

  public function new(el:Element) {
    super(el);
    update();
  }

  public function update() {
    if (shouldRender()) {
      var result = render();
      if (result != null) {
        Renderer.render(result, el);
      }
    }
  }

  public function shouldRender():Bool {
    return true;
  }

  public function render():Null<TemplateResult> {
    return null;
  }

}


@:element('todo-input')
class TodoInput extends UpdatingElement {

  @:isVar var label(default, set):String;
  public function set_label(label) {
    this.label = label;
    update();
    return label;
  }
  @:isVar var value(default, set):String;
  public function set_value(value) {
    this.value = value;
    update();
    return value;
  }
  @:isVar var onSubmit(default, set):(value:String)->Void;
  public function set_onSubmit(onSubmit) {
    this.onSubmit = onSubmit;
    update();
    return onSubmit;
  }

  function handleChange(e:Event) {
    var input:InputElement = cast e.target;
    value = input.value;
  }

  function handleSubmit(e:Event) {
    e.preventDefault();
    onSubmit(value);
    value = '';
    update();
  }

  override function render() return html('
    <input 
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

  @:isVar public var todo(default, set):Todo;
  function set_todo(todo) {
    this.todo = todo;
    update();
    return todo;
  }

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

  @:isVar public var todos(default, set):Array<Todo>;
  function set_todos(todos) {
    this.todos = todos;
    update();
    return todos;
  }
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