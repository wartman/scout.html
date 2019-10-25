package todo.ui;

import todo.data.*;

abstract AppHeader(Result) to Result {
  
  public function new(props:{
    title:String,
    store:Store
  }) {
    this = html(<header class="todo-header">
      <h1>{props.title}</h1>
      <todo.ui.TodoInput
        inputClass="add"
        placeholder="What needs doing?"
        value=""
        save={ value -> props.store.addTodo(new Todo(value)) }
      />
    </header>);
  }

}
