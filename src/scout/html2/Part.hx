package scout.html2;

interface Part {
  public function set(value:Value):Void;
  public function commit():Void;
  public function dispose():Void;
}
