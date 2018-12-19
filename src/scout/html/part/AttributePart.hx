package scout.html.part;

import scout.html.Part;

class AttributePart implements Part {

  final committer:AttributeCommitter;
  @:isVar public var value(get, set):Dynamic;
  public function set_value(value:Dynamic) {
    if (value != null && value != this.value) {
      this.value = value;
      committer.dirty = true;
    }
    return value;
  }
  public function get_value() return this.value;

  public function new(committer:AttributeCommitter) {
    this.committer = committer;
  }

  public function commit() {
    committer.commit();
  }

}
