package mdpm.sql.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.sql.oscar.g.SqlParser;

public class NumberTest extends SqlParserTest {

  @Test
  public void parseNumbers01() {
    SqlParser p = parse("25");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric 25)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers02() {
    SqlParser p = parse("+6.34");
    ParseTree t = p.expression();
    assertEquals("(expression (value + (numeric 6.34)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers03() {
    SqlParser p = parse("-6.34");
    ParseTree t = p.expression();
    assertEquals("(expression (value - (numeric 6.34)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers04() {
    SqlParser p = parse("0.5");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric 0.5)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers05() {
    SqlParser p = parse("25e-3");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric 25e-3)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers06() {
    SqlParser p = parse("-25e-3");
    ParseTree t = p.expression();
    assertEquals("(expression (value - (numeric 25e-3)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers07() {
    SqlParser p = parse("25f");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric 25f)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers08() {
    SqlParser p = parse("+6.34F");
    ParseTree t = p.expression();
    assertEquals("(expression (value + (numeric 6.34F)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers09() {
    SqlParser p = parse("0.5d");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric 0.5d)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers10() {
    SqlParser p = parse(".05");
    ParseTree t = p.expression();
    assertEquals("(expression (value (numeric .05)))", t.toStringTree(p));
  }

  @Test
  public void parseNumbers11() {
    SqlParser p = parse("-1D");
    ParseTree t = p.expression();
    assertEquals("(expression (value - (numeric 1D)))", t.toStringTree(p));
  }

}