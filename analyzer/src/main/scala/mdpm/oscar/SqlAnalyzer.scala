package mdpm.oscar

import org.antlr.v4.runtime.tree._
import mdpm.oscar.g.SqlParser._

object SqlAnalyzer {
  import internal.columns._

  def getColumnRefs(tree: ParseTree): List[(Schema, Table, Name)] =
    (resolve compose collect)(tree)

}
