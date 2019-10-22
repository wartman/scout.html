package scout.html2;

class Property implements Part {
  
  final committer:(value:Value, oldValue:Value)->Void;
  var currentValue:Value;
  var pendingValue:Value;

  public function new(committer) {
    this.committer = committer;
  }

  public function set(value:Value) {
    pendingValue = value;
  }

  public function commit() {
    if (pendingValue != currentValue) {
      committer(pendingValue, currentValue);
    }
    currentValue = pendingValue;
  }

  public function dispose() {
    // noop
  }

}
