package mdpm.oscar
package internal

import scala.collection._

import org.antlr.v4.runtime._
import org.antlr.v4.runtime.tree._

import mdpm.oscar.g.SqlParser._
import mdpm.oscar.g.SqlBaseListener

private[oscar] object columns {

  case class ColumnRef(path: Option[(Option[Schema], Table)], name: Name, alias: Option[Alias])

  type RefT = IdentityHashMap[SimpleQueryContext, (List[ColumnRef], List[TableContext])]

  type SymT = IdentityHashMap[SubselectContext, RefT]

  val collect: ParseTree => SymT = tree => {
    val walker = new ParseTreeWalker
    val worker = new Refs
    walker.walk(worker, tree)
    worker.st
  }

  val resolve: SymT => List[(Schema, Table, Name)] = st => {
    // DEBUG START {{{
    println("~~~")
    st.foreach { case (ss,qs) =>
      println("Subselect with: ")
      qs map { case (q, (cs, fs)) =>
        println("  Query   : " + q.getText)
        println("  Columns : " + (cs.reverse mkString ", "))
        println("  Context : " + (fs.map(t => {
        val name = Option(t.name()).map(_.getText).getOrElse(
          Option(t.subselect()).map(x => "<<subselect>> (" + st.get(x).isDefined + ")").getOrElse(
            Option(t.table_collection_expression()).map(_ => "<<table collection>>").get))
        Option(t.alias()).map(x => x.getText + " --> " + name).getOrElse(name)
        }) mkString ", "))
      }
      println("---")
    }
    // DEBUG END
    Nil
  }

  private[internal] class Refs extends SqlBaseListener {
    import scalaz.std.option._
    import scalaz.syntax.std.boolean._

    val as = mutable.Stack.empty[Option[String]]
    val sc = mutable.Stack.empty[SubselectContext]
    val qc = mutable.Stack.empty[SimpleQueryContext]
    val st = IdentityHashMap.empty[SubselectContext, RefT]

    override def enterSubselect(ctx: SubselectContext): Unit = {
      sc push ctx
      st += ctx -> IdentityHashMap.empty[SimpleQueryContext, (List[ColumnRef], List[TableContext])]
    }

    override def exitSubselect(ctx: SubselectContext): Unit =
      sc.pop()

    override def enterSimpleQuery(ctx: SimpleQueryContext): Unit = {
      qc push ctx
      st(sc.top) += ctx -> (Nil, Nil)
    }

    override def exitSimpleQuery(ctx: SimpleQueryContext): Unit =
      qc.pop()

    override def enterColumn(ctx: ColumnContext): Unit = {
      val (cs, fs) = st(sc.top)(qc.top)
      val ref = ColumnRef(
        Option(ctx.alias()).map(x => (Option(ctx.schema()).map(_.getText()), x.getText()))
      , ctx.name().getText()
      , !as.isEmpty ? as.top | none
      )
      st(sc.top) += qc.top -> (ref :: cs, fs)
    }

    override def enterTable(ctx: TableContext): Unit = {
      val (cs, fs) = st(sc.top)(qc.top)
      st(sc.top) += qc.top -> (cs, ctx :: fs)
    }

    override def enterSelectElementExp(ctx: SelectElementExpContext): Unit =
      as push Option(ctx.alias()).map(_.getText)

    override def exitSelectElementExp(ctx: SelectElementExpContext): Unit =
      as.isEmpty.unless(as.pop())

    override def enterSelectElementSub(ctx: SelectElementSubContext): Unit =
      as push Option(ctx.alias()).map(_.getText)

    override def exitSelectElementSub(ctx: SelectElementSubContext): Unit =
      as.isEmpty.unless(as.pop())

    override def enterFunction(ctx: FunctionContext): Unit =
      as.isEmpty.unless(as.pop())

    override def enterSimpleCaseExp(ctx: SimpleCaseExpContext): Unit =
      as.isEmpty.unless(as.pop())

    override def enterSearchedCaseExp(ctx: SearchedCaseExpContext): Unit =
      as.isEmpty.unless(as.pop())

  }

}