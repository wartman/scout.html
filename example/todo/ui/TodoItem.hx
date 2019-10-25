package todo.ui;

import todo.data.*;

abstract TodoItem(Result) to Result {

  public function new(props:{
    todo:Todo,
    store:Store
  }) {
    this = html(
      <li class="todo-item">
        <p>{props.todo.content}</p>
        <button
          onClick={_ -> {
            trace(props.todo);
            trace(props.store);
            props.store.removeTodo(props.todo);
          }}
        >X</button>
      </li>
    );
  }

}
