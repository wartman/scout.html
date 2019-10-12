package todo.ui;

import todo.data.Todo;

abstract TodoList(TemplateResult) to TemplateResult {

  public function new(props:{
    todos:Array<Todo>
  }) {
    this = html('
      <ul class="todo-list">
        <for {todo in props.todos}>
          <TodoItem todo={todo} />
        </for>
      </ul>
    ');
  }

}
