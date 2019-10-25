package todo;

import js.Browser;
import todo.data.*;
import todo.ui.*;

class TodoApp {

  static function main() {
    var store = new Store(
      store -> html(<App store={store} />),
      Browser.document.body
    );
    store.update();
  }

}