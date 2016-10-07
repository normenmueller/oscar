package mdpm.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.oscar.g.SqlParser;

public class DateTest extends SqlParserTest {

  @Test
  public void parseDates01() {
    SqlParser p = parse("DATE '1998-12-25'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (datetime DATE (expression (value (string '1998-12-25'))))))", t.toStringTree(p));
  }

  @Test
  public void parseDates02() {
    SqlParser p = parse("TO_DATE('98-DEC-25 17:30','YY-MON-DD HH24:MI')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '98-DEC-25 17:30')))) , (parameter (expression (value (string 'YY-MON-DD HH24:MI'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseDates03() {
    SqlParser p = parse("TIMESTAMP '1997-01-31 09:26:50.124'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (datetime TIMESTAMP (expression (value (string '1997-01-31 09:26:50.124'))))))", t.toStringTree(p));
  }

  @Test
  public void parseDates04() {
    SqlParser p = parse("TIMESTAMP '2009-10-29 01:30:00' AT TIME ZONE 'US/Pacific'");
    ParseTree t = p.expression();
    assertEquals("(expression (value (datetime TIMESTAMP (expression (expression (value (string '2009-10-29 01:30:00'))) AT TIME ZONE (expression (value (string 'US/Pacific')))))))", t.toStringTree(p));
  }

  @Test
  public void parseDates05() {
    SqlParser p = parse("TIMESTAMP WITH LOCAL TIME ZONE");
    ParseTree t = p.expression();
    assertEquals("(expression (value (datetime TIMESTAMP WITH LOCAL TIME ZONE)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals01() {
    SqlParser p = parse("INTERVAL '123-2' YEAR(3) TO MONTH");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '123-2') YEAR ( (expression (value (numeric 3))) ) TO MONTH)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals02() {
    SqlParser p = parse("INTERVAL '123' YEAR(3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '123') YEAR ( (expression (value (numeric 3))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals03() {
    SqlParser p = parse("INTERVAL '300' MONTH(3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '300') MONTH ( (expression (value (numeric 3))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals04() {
    SqlParser p = parse("INTERVAL '4' YEAR");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '4') YEAR)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals05() {
    SqlParser p = parse("INTERVAL '50' MONTH");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '50') MONTH)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals06() {
    SqlParser p = parse("INTERVAL '123' YEAR");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '123') YEAR)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals07() {
    SqlParser p = parse("INTERVAL '4 5:12:10.222' DAY TO SECOND(3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '4 5:12:10.222') DAY TO SECOND ( (expression (value (numeric 3))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals08() {
    SqlParser p = parse("INTERVAL '4 5:12' DAY TO MINUTE");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '4 5:12') DAY TO MINUTE)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals09() {
    SqlParser p = parse("INTERVAL '400 5' DAY(3) TO HOUR");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '400 5') DAY ( (expression (value (numeric 3))) ) TO HOUR)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals10() {
    SqlParser p = parse("INTERVAL '400' DAY(3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '400') DAY ( (expression (value (numeric 3))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals11() {
    SqlParser p = parse("INTERVAL '11:12:10.2222222' HOUR TO SECOND(7)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '11:12:10.2222222') HOUR TO SECOND ( (expression (value (numeric 7))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals12() {
    SqlParser p = parse("INTERVAL '11:20' HOUR TO MINUTE");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '11:20') HOUR TO MINUTE)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals13() {
    SqlParser p = parse("INTERVAL '10' HOUR");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '10') HOUR)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals14() {
    SqlParser p = parse("INTERVAL '10:22' MINUTE TO SECOND");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '10:22') MINUTE TO SECOND)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals15() {
    SqlParser p = parse("INTERVAL '10' MINUTE");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '10') MINUTE)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals16() {
    SqlParser p = parse("INTERVAL '4' DAY");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '4') DAY)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals17() {
    SqlParser p = parse("INTERVAL '25' HOUR");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '25') HOUR)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals18() {
    SqlParser p = parse("INTERVAL '40' MINUTE");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '40') MINUTE)))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals19() {
    SqlParser p = parse("INTERVAL '120' HOUR(3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '120') HOUR ( (expression (value (numeric 3))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseIntervals20() {
    SqlParser p = parse("INTERVAL '30.12345' SECOND(2,4)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (interval INTERVAL (string '30.12345') SECOND ( (expression (value (numeric 2))) , (expression (value (numeric 4))) ))))", t.toStringTree(p));
  }

}