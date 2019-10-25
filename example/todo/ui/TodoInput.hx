package todo.ui;

class TodoInput extends Component {
  
  @:attribute var inputClass:String = 'edit';
  @:attribute var placeholder:String = 'What needs doing?';
  @:attribute var value:String;
  @:attribute var save:(value:String)->Void;

  override function render():Result {
    return html(<div class="todo-edit">
      <input 
        type="text"
        class={inputClass}
        value={value}
        placeholder={placeholder}
        onKeyDown={e -> {
          var input:js.html.InputElement = cast e.target;
          var keyboardEvent:js.html.KeyboardEvent = cast e;
          if (keyboardEvent.key == 'Enter') {
            save(input.value);
            input.value = '';
            input.blur();
          }
        }} 
      />
    </div>);
  }

}