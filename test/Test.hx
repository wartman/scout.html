import js.html.InputElement;
import js.html.Event;
import js.Browser;
import scout.html.Api.html;
import scout.html.TemplateResult;
import scout.html.Component;

using scout.html.Renderer;

class Test {

  public static function main() {
    var todos = new TodoCollection([
      new Todo(0, 'Do it', false),
      new Todo(1, 'Do it also', false)
    ]);
    new TodoList({ todos: todos })
      .renderComponent(Browser.document.getElementById('root'));
  }

}

class Todo {
  
  public var id:Int;
  public var content:String;
  public var completed:Bool;
  public var editing:Bool = false;
  public var collection:TodoCollection;

  public function new(id, content, completed) {
    this.id = id;
    this.content = content;
    this.completed = completed;
  }

  public function remove() {
    if (collection != null) {
      collection.remove(this);
    }
  }

}

class TodoCollection {

  public final todos:Array<Todo> = [];
  final actions:Array<()->Void> = [];

  public function new(todos:Array<Todo>) {
    for (todo in todos) add(todo);
  }

  public function add(todo:Todo) {
    todo.collection = this;
    todos.push(todo);
    for (todo in todos) {
      todo.editing = false;
    }
    update();
  }

  public function remove(todo:Todo) {
    todo.collection = null;
    todos.remove(todo);
    update();
  }

  public function subscribe(action:()->Void) {
    actions.push(action);
  }

  function update() {
    for (action in actions) action();
  }

}

class TodoInput extends Component {

  @:prop var value:String;
  @:prop var label:String;
  @:prop var onSubmit:(value:String)->Void;

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

class TodoItem extends Component {

  @:prop var todo:Todo;

  function toggleEditing() {
    todo.editing = true;
    update();
  }

  function removeItem() {
    todo.remove();
    trace('removed');
  }

  override function render() return html('
    <li class="todo-item">
      ${ if (todo.editing) new TodoInput({
        value: todo.content,
        label: 'Update',
        onSubmit: value -> {
          todo.editing = false;
          todo.content = value;
          update();
        }
      }) else html(' 
        <label>${todo.content}</label>
        <button class="edit" on:click="${_ -> toggleEditing()}">Edit</button>
        <button class="destroy" on:click="${_ -> removeItem()}">Remove</button>
      ') }
    </li>
  ');

}

class UpdatingList extends Component {

  @:prop var className:String;
  @:prop var todos:TodoCollection;

  @:init function watchTodos() {
    todos.subscribe(() -> update());
  }

  override function render() return html('
    <ul class="${className}">
      ${[ for (todo in todos.todos) new TodoItem({ todo: todo }) ]}
    </ul>
  ');

}

class TodoList extends Component {

  @:prop var todos:TodoCollection;

  override function render():TemplateResult return [
    html('<header>
      <h1>Todo</h1>
    </header>'),
    new TodoInput({
      value: '',
      label: 'Create',
      onSubmit: (value:String) -> {
        var todo = new Todo(todos.todos.length, value, false);
        todos.add(todo);
      }
    }),
    new UpdatingList({
      className: 'todo-items',
      todos: todos
    })
  ];

}
