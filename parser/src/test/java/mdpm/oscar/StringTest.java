package mdpm.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.oscar.g.SqlParser;

public class StringTest extends SqlParserTest {

  @Test
  public void parseStrings01() {
    SqlParser p = parse("'Hello'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string 'Hello')))", t.toStringTree(p));
    }

  @Test
  public void parseStrings02() {
    SqlParser p = parse("'ORACLE.dbs'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string 'ORACLE.dbs')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings03() {
    SqlParser p = parse("'Jackie''s raincoat'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string 'Jackie''s raincoat')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings04() {
    SqlParser p = parse("'09-MAR-98'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string '09-MAR-98')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings05() {
    SqlParser p = parse("'\\0308'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string '\\0308')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings06() {
    SqlParser p = parse("N'nchar literal'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string N'nchar literal')))", t.toStringTree(p));
  }
    
  @Test
  public void parseStrings07() {
    SqlParser p = parse("q'!name LIKE '%DBMS_%%'!'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string q'!name LIKE '%DBMS_%%'!')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings08() {
    SqlParser p = parse("q'<'So,' she said, 'It's finished.'>'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string q'<'So,' she said, 'It's finished.'>')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings09() {
    SqlParser p = parse("q'{SELECT * FROM employees WHERE last_name = 'Smith';}'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string q'{SELECT * FROM employees WHERE last_name = 'Smith';}')))", t.toStringTree(p));
  }

  @Test
  public void parseStrings10() {
    SqlParser p = parse("q'\"name like '['\"'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (string q'\"name like '['\"')))", t.toStringTree(p));
  }

}