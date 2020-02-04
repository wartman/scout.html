package scout.html;

import scout.html.Template.*;

using Medic;

class TemplateTest implements TestCase {

  public function new() {}

  @test('Check reentrency')
  public function reentrency() {
    var root = js.Browser.document.createElement('div');
    var tpl = (stuff:Array<String>) -> html(<ul>
      ${ [ for (item in stuff) <li>${item}</li> ]  }
    </ul>);
    render(tpl(['a', 'b', 'c']), root);
    root.innerHTML.equals('<!--  --><ul><!--  --><!--  --><li><!--  -->a<!--  --></li><!--  --><li><!--  -->b<!--  --></li><!--  --><li><!--  -->c<!--  --></li><!--  --><!--  --></ul><!--  -->');
  }

}
