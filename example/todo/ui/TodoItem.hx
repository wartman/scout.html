package todo.ui;

import todo.data.Todo;

abstract TodoItem(TemplateResult) to TemplateResult {

  public function new(props:{
    todo:Todo
  }) {
    this = html(
      <li class="todo-item">
        <p>{props.todo.content}</p>
      </li>
    );
  }

}
