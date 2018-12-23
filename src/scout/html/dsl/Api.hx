package scout.html.dsl;

class Api {

  public static macro function build(e) {
    var node = Parser.parse(e);
    return new Generator(node).generate();
  } 

}
