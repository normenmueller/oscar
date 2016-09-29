package mdpm.sql.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.sql.oscar.g.SqlParser;

public class MiscTest extends SqlParserTest {

  @Test
  public void parseColumnReferences() {
    SqlParser p0 = parse("c");
    ParseTree t0 = p0.expression();
    assertEquals("(expression (value (column (name c))))", t0.toStringTree(p0));

    // NOTE Depending on the order of the `value` rule
    //      the parser could identify `t.c` as a user defined
    //      function `c` in package `t`
    SqlParser p1 = parse("t.c");
    ParseTree t1 = p1.expression();
    assertEquals("(expression (value (column (table_alias (name t)) . (name c))))", t1.toStringTree(p1));

    // NOTE Depending on the order of the `value` rule
    //      the parser could identify `s.t.c` as a user
    //      defined function `c` in package `t` of schema `s`.
    SqlParser p2 = parse("s.t.c");
    ParseTree t2 = p2.expression();
    assertEquals("(expression (value (column (schema s) . (table_alias (name t)) . (name c))))", t2.toStringTree(p2));
  }
 
  @Test
  public void parseExpressionLists() { // TODO Valid?
    {
    SqlParser p = parse("( (co.country_region, co.country_subregion), (co.country_region, co.country_subregion) )");
    ParseTree t = p.expression();
    assertEquals("(expression ( (expression ( (expression (value (column (table_alias (name co)) . (name country_region)))) , (expression (value (column (table_alias (name co)) . (name country_subregion)))) )) , (expression ( (expression (value (column (table_alias (name co)) . (name country_region)))) , (expression (value (column (table_alias (name co)) . (name country_subregion)))) )) ))", t.toStringTree(p));
    }
  }

}