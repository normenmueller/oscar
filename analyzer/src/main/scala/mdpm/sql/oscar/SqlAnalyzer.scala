package mdpm.sql.oscar

import mdpm.sql.oscar.g.SqlParser.{ StatementContext, ColumnContext }
import mdpm.sql.oscar.g.SqlBaseVisitor

object SqlAnalyzer {
  type Statement = StatementContext

  // TODO wip
  def columns(tree: Statement): List[String] = {
    new SqlBaseVisitor[String] {
      override def visitColumn(ctx: ColumnContext): String = {
        visitChildren(ctx)
      }
    }.visit(tree)

    Nil
  }

}
