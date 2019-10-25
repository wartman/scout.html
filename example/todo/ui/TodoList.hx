package todo.ui;

import todo.data.*;

abstract TodoList(Result) to Result {

  public function new(props:{
    store:Store,
    todos:Array<Todo>
  }) {
    this = html(
      <ul class="todo-list">
        <for {todo in props.todos}>
          <TodoItem todo={todo} store={props.store} />
        </for>
      </ul>
    );
  }

}
