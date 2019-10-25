package todo.ui;

import todo.data.Store;

class App extends Component {
  
  @:attribute var store:Store;

  override function render():Result {
    return html(<>
      <AppHeader title="Todo" store={store} />
      <TodoList todos={store.visibleTodos} store={store} />
    </>);
  }

}