package scout.html;

import scout.html.dom.*;
import scout.html.Template;

using Medic;

class TemplateTest implements TestCase {

  public function new() {}

  @test('Check reentrency')
  public function reentrency() {
    var root = Document.root.createElement('div');
    var tpl = (stuff:Array<String>) -> Template.html(<ul>
      ${ [ for (item in stuff) <li>${item}</li> ]  }
    </ul>);
    Template.render(tpl(['a', 'b', 'c']), root);
    root.innerHTML.equals('<!--  --><ul><!--  --><!--  --><li><!--  -->a<!--  --></li><!--  --><li><!--  -->b<!--  --></li><!--  --><li><!--  -->c<!--  --></li><!--  --><!--  --></ul><!--  -->');
  }

}
