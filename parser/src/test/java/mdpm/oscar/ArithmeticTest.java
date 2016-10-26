package mdpm.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.oscar.g.SqlParser;

public class ArithmeticTest extends SqlParserTest {

  @Test
  public void parseExpression01() {
    SqlParser p = parse("-5");
    ParseTree t = p.expression();
    assertEquals("(expression (value - (numeric 5)))", t.toStringTree(p));
  }

  @Test
  public void parseExpression02() {
    SqlParser p = parse("5-4");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (numeric 5))) - (expression (value (numeric 4))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression03() {
    SqlParser p = parse("-5-4");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value - (numeric 5))) - (expression (value (numeric 4))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression04() {
    SqlParser p = parse("2*3+4");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (expression (value (numeric 2))) * (expression (value (numeric 3)))) + (expression (value (numeric 4))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression05() {
    /* As to the Oracle specification:
     * Do not use two consecutive minus signs (--) in arithmetic expressions to indicate double negation or
     * the subtraction of a negative value. The characters -- are used to begin comments within SQL statements.
     * You should separate consecutive minus signs with a space or parentheses.
     */
    SqlParser p = parse("5 - -4");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (numeric 5))) - (expression (value - (numeric 4))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression06() {
    SqlParser p = parse("5 - a_column");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (numeric 5))) - (expression (value (column (name a_column)))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression07() {
    SqlParser p = parse("5 - -a_column");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (numeric 5))) - (expression (value - (column (name a_column)))))", t.toStringTree(p));
  }

  @Test
  public void parseExpression08() {
    SqlParser p = parse("2*3*4");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (expression (value (numeric 2))) * (expression (value (numeric 3)))) * (expression (value (numeric 4))))", t.toStringTree(p));
  }
  
}