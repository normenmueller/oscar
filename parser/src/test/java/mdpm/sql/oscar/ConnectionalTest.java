package mdpm.sql.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.sql.oscar.g.SqlParser;

public class ConnectionalTest extends SqlParserTest {

  @Test
  public void parseConnectionals1() {
    SqlParser p = parse("'Name is ' || last_name");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (string 'Name is '))) || (expression (value (column (name last_name)))))", t.toStringTree(p));
  }

  @Test
  public void parseConnectionals2() {
    SqlParser p = parse("'Name is ' || last_name || fist_name || '!'");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (expression (expression (value (string 'Name is '))) || (expression (value (column (name last_name))))) || (expression (value (column (name fist_name))))) || (expression (value (string '!'))))", t.toStringTree(p));
  }

  @Test
  public void parseConnectionals3() {
    SqlParser p = parse("CHR(67)||CHR(65)||CHR(84)");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (expression (value (function (name CHR) ( (parameters (parameter (expression (value (numeric 67))))) )))) || (expression (value (function (name CHR) ( (parameters (parameter (expression (value (numeric 65))))) ))))) || (expression (value (function (name CHR) ( (parameters (parameter (expression (value (numeric 84))))) )))))", t.toStringTree(p));
  }

}