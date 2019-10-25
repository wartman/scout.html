package scout.html;

interface Part {
  public function set(value:Value):Void;
  public function commit():Void;
  public function dispose():Void;
}
