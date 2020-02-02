using Medic;

class Test {

  public static function main() {
    var runner = new Runner();
    runner.add(new scout.html.TemplateTest());
    runner.run();
  }

}