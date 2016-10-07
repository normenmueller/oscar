package mdpm.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Ignore;
import org.junit.Test;

import mdpm.oscar.g.SqlParser;

public class ConditionalTest extends SqlParserTest {

  @Test
  public void parseConditional01() {
    SqlParser p = parse("aCol = bCol AND cCol = dCol");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (comparison (expression (value (column (name aCol)))) = (expression (value (column (name bCol)))))) AND (condition (comparison (expression (value (column (name cCol)))) = (expression (value (column (name dCol)))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional02() {
    SqlParser p = parse("aCol = bCol OR cCol = dCol");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (comparison (expression (value (column (name aCol)))) = (expression (value (column (name bCol)))))) OR (condition (comparison (expression (value (column (name cCol)))) = (expression (value (column (name dCol)))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional03() {
    SqlParser p = parse("aCol = bCol AND cCol = dCol AND eCol > fCol");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (condition (comparison (expression (value (column (name aCol)))) = (expression (value (column (name bCol)))))) AND (condition (comparison (expression (value (column (name cCol)))) = (expression (value (column (name dCol))))))) AND (condition (comparison (expression (value (column (name eCol)))) > (expression (value (column (name fCol)))))))", t.toStringTree(p));
  }

  @Ignore@Test
  public void parseConditional04() { // FIXME
    //SqlParser p = parse("aCol is of XMLType AND cCol = dCol");
    //ParseTree t = p.condition();
    //assertEquals("(condition (condition (expression (value (column (name aCol)))) is of (datatype (special_datatype XMLType))) AND (condition (comparison (expression (value (column (name cCol)))) = (expression (value (column (name dCol)))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional05() {
    SqlParser p = parse("aCol = bCol AND cCol != dCol OR eCol > fCol");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (condition (comparison (expression (value (column (name aCol)))) = (expression (value (column (name bCol)))))) AND (condition (comparison (expression (value (column (name cCol)))) != (expression (value (column (name dCol))))))) OR (condition (comparison (expression (value (column (name eCol)))) > (expression (value (column (name fCol)))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional06() {
    SqlParser p = parse("5 * 3 > 4");
    ParseTree t = p.condition();
    assertEquals("(condition (comparison (expression (expression (value (numeric 5))) * (expression (value (numeric 3)))) > (expression (value (numeric 4)))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional07() {
    SqlParser p = parse("-salary < 0");
    ParseTree t = p.condition();
    assertEquals("(condition (comparison (expression (value - (column (name salary)))) < (expression (value (numeric 0)))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional08() {
    SqlParser p = parse("0 < -salary");
    ParseTree t = p.condition();
    assertEquals("(condition (comparison (expression (value (numeric 0))) < (expression (value - (column (name salary))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional09() {
    SqlParser p = parse("LNNVL(commission_pct >= .2)");
    ParseTree t = p.condition();
    assertEquals("(condition LNNVL ( (condition (comparison (expression (value (column (name commission_pct)))) >= (expression (value (numeric .2))))) ))", t.toStringTree(p));
  }
    
  @Test
  public void parseConditional10() {
    SqlParser p = parse("NVL(salary, 0) + NVL(commission_pct, 0) > 25000");
    ParseTree t = p.condition();
    assertEquals("(condition (comparison (expression (expression (value (function (name NVL) ( (parameters (parameter (expression (value (column (name salary))))) , (parameter (expression (value (numeric 0))))) )))) + (expression (value (function (name NVL) ( (parameters (parameter (expression (value (column (name commission_pct))))) , (parameter (expression (value (numeric 0))))) ))))) > (expression (value (numeric 25000)))))", t.toStringTree(p));
  }
    
  @Test
  public void parseConditional11() {
    SqlParser p = parse("(1 = 1) AND (5 < 7)");
    ParseTree t = p.condition();
    assertEquals("(condition (condition ( (condition (comparison (expression (value (numeric 1))) = (expression (value (numeric 1))))) )) AND (condition ( (condition (comparison (expression (value (numeric 5))) < (expression (value (numeric 7))))) )))", t.toStringTree(p));
  }

  //@Test
  //public void parseConditional12() { // TODO Valid?
  //  SqlParser p = parse("(1, 2, 3) = ANY (6, 7, 1)");
  //  ParseTree t = p.condition();
  //  assertEquals("(condition (comparison (expression ( (expression (value (numeric 1))) , (expression (value (numeric 2))) , (expression (value (numeric 3))) )) = ANY (expression ( (expression (value (numeric 6))) , (expression (value (numeric 7))) , (expression (value (numeric 1))) ))))", t.toStringTree(p));
  //}

  @Test
  public void parseConditional13() {
    SqlParser p = parse("commission_pct IS NOT NAN");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name commission_pct)))) IS NOT NAN)", t.toStringTree(p));
  }

  @Test
  public void parseConditional14() {
    SqlParser p = parse("salary IS NOT INFINITE");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name salary)))) IS NOT INFINITE)", t.toStringTree(p));
  }

  @Test
  public void parseConditional15() {
    SqlParser p = parse("NOT (job_id IS NULL)");
    ParseTree t = p.condition();
    assertEquals("(condition NOT (condition ( (condition (expression (value (column (name job_id)))) IS NULL) )))", t.toStringTree(p));
  }

  @Test
  public void parseConditional16() {
    SqlParser p = parse("NOT (salary BETWEEN 1000 AND 2000)");
    ParseTree t = p.condition();
    assertEquals("(condition NOT (condition ( (condition (expression (value (column (name salary)))) BETWEEN (expression (value (numeric 1000))) AND (expression (value (numeric 2000)))) )))", t.toStringTree(p));
  }

  @Test
  public void parseConditional17() {
    SqlParser p = parse("job_id = 'PU_CLERK' AND department_id = 30");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (comparison (expression (value (column (name job_id)))) = (expression (value (string 'PU_CLERK'))))) AND (condition (comparison (expression (value (column (name department_id)))) = (expression (value (numeric 30))))))", t.toStringTree(p));
    }

  @Test
  public void parseConditional18() {
    SqlParser p = parse("job_id = 'PU_CLERK' OR department_id = 10");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (comparison (expression (value (column (name job_id)))) = (expression (value (string 'PU_CLERK'))))) OR (condition (comparison (expression (value (column (name department_id)))) = (expression (value (numeric 10))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional19() {
    SqlParser p = parse("hire_date < TO_DATE('01-JAN-2004', 'DD-MON-YYYY') AND salary > 2500");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (comparison (expression (value (column (name hire_date)))) < (expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '01-JAN-2004')))) , (parameter (expression (value (string 'DD-MON-YYYY'))))) )))))) AND (condition (comparison (expression (value (column (name salary)))) > (expression (value (numeric 2500))))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional20() {
    SqlParser p = parse("cust_address_ntab IS A      SET");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name cust_address_ntab)))) IS A SET)", t.toStringTree(p));
  }

  @Test
  public void parseConditional21() {
    SqlParser p = parse("cust_address_ntab IS NOT   A  SET");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name cust_address_ntab)))) IS NOT A SET)", t.toStringTree(p));
  }

  @Test
  public void parseConditional22() {
    SqlParser p = parse("ad_textdocs_ntab IS NOT EMPTY");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name ad_textdocs_ntab)))) IS NOT EMPTY)", t.toStringTree(p));
  }

  @Test
  public void parseConditional23() { // TODO re-assess
    // original: SqlParser p = parse("         cust_address_typ('8768 N State Rd 37', 47404, 'Bloomington', 'IN', 'US') MEMBER OF cust_address_ntab");
                 SqlParser p = parse("aPackage.cust_address_typ('8768 N State Rd 37', 47404, 'Bloomington', 'IN', 'US') MEMBER OF cust_address_ntab");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (function (name (pkg aPackage) . cust_address_typ) ( (parameters (parameter (expression (value (string '8768 N State Rd 37')))) , (parameter (expression (value (numeric 47404)))) , (parameter (expression (value (string 'Bloomington')))) , (parameter (expression (value (string 'IN')))) , (parameter (expression (value (string 'US'))))) )))) MEMBER OF (alias (name cust_address_ntab)))", t.toStringTree(p));
  }

  @Test
  public void parseConditional24() {
    SqlParser p = parse("cust_address_ntab SUBMULTISET OF cust_address2_ntab");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name cust_address_ntab)))) SUBMULTISET OF (alias (name cust_address2_ntab)))", t.toStringTree(p));
  }

  @Test
  public void parseConditional25() {
    SqlParser p = parse("last_name LIKE '%A\\_B%' ESCAPE '\\'");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (column (name last_name)))) LIKE (expression (value (string '%A\\_B%'))) ESCAPE (expression (value (string '\\'))))", t.toStringTree(p));
  }

  @Test
  public void parseConditional26() {
    SqlParser p = parse("'SM%' LIKE last_name");
    ParseTree t = p.condition();
    assertEquals("(condition (expression (value (string 'SM%'))) LIKE (expression (value (column (name last_name)))))", t.toStringTree(p));
    }

  @Test
  public void parseConditional27() {
    SqlParser p = parse("REGEXP_LIKE (first_name, '^Ste(v|ph)en$')");
    ParseTree t = p.condition();
    assertEquals("(condition REGEXP_LIKE ( (expression (value (column (name first_name)))) , (expression (value (string '^Ste(v|ph)en$'))) ))", t.toStringTree(p));
  }
 
  @Test
  public void parseConditional28() {
    SqlParser p = parse("pty_sk = prim_pty_sk and nvl(PTY_STUS_INDCTR,' ') != 'D' and exists (select * from ma_i_pty /* TEMPL SQF_TGT */ where scndy_pty_sk = pty_sk and PTY_SRC_NME = 'BB_GUAR')");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (condition (comparison (expression (value (column (name pty_sk)))) = (expression (value (column (name prim_pty_sk)))))) and (condition (comparison (expression (value (function (name nvl) ( (parameters (parameter (expression (value (column (name PTY_STUS_INDCTR))))) , (parameter (expression (value (string ' '))))) )))) != (expression (value (string 'D')))))) and (condition exists ( (subselect (query (select_clause select (select_elements (select_element (expression (value (column (name *))))))) (from_clause from (from_elements (from_element (table (name ma_i_pty))))) (where_clause where (condition (condition (comparison (expression (value (column (name scndy_pty_sk)))) = (expression (value (column (name pty_sk)))))) and (condition (comparison (expression (value (column (name PTY_SRC_NME)))) = (expression (value (string 'BB_GUAR'))))))))) )))", t.toStringTree(p));
  }
 
  @Test
  public void parseConditional29() {
    SqlParser p = parse("can_be_used=1 and CPYTYPB3 in ('J', 'K') and DPST_TYP_ID in (1,2,3,4,5,7) and (INS_TXNL_ACT_FLG+INS_NON_TXNL_RELP_BSD_ACT_FLG)>0 and nvl(INS_NON_QUAL_ACT_FLG,0) <> 1");
    ParseTree t = p.condition();
    assertEquals("(condition (condition (condition (condition (condition (comparison (expression (value (column (name can_be_used)))) = (expression (value (numeric 1))))) and (condition (expression (value (column (name CPYTYPB3)))) in (expression ( (expression (value (string 'J'))) , (expression (value (string 'K'))) )))) and (condition (expression (value (column (name DPST_TYP_ID)))) in (expression ( (expression (value (numeric 1))) , (expression (value (numeric 2))) , (expression (value (numeric 3))) , (expression (value (numeric 4))) , (expression (value (numeric 5))) , (expression (value (numeric 7))) )))) and (condition (comparison (expression ( (expression (expression (value (column (name INS_TXNL_ACT_FLG)))) + (expression (value (column (name INS_NON_TXNL_RELP_BSD_ACT_FLG))))) )) > (expression (value (numeric 0)))))) and (condition (comparison (expression (value (function (name nvl) ( (parameters (parameter (expression (value (column (name INS_NON_QUAL_ACT_FLG))))) , (parameter (expression (value (numeric 0))))) )))) <> (expression (value (numeric 1))))))", t.toStringTree(p));
  }
}