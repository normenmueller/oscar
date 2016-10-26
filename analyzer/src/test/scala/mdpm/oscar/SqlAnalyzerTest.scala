package mdpm.oscar

import java.nio.file.{ Files, Paths }

import mdpm.oscar.g.SqlParser.StatementContext

trait SqlAnalyzerTest {

  val slurp = (file: String) => new String(Files.readAllBytes(Paths.get(file)))

  val parse = mdpm.oscar.SqlParser.parse _

  val crefs = mdpm.oscar.SqlAnalyzer.getColumnRefs _

}