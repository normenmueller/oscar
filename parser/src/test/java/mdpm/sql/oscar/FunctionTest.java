package mdpm.sql.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.sql.oscar.g.SqlParser;

public class FunctionTest extends SqlParserTest {

  @Test
  public void parseFunctions01() {
    SqlParser p = parse("ABS(-5)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ABS) ( (parameters (parameter (expression (value - (numeric 5))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions02() {
    SqlParser p = parse("ABS(ACOS(-5 * 3+4))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ABS) ( (parameters (parameter (expression (value (function (name ACOS) ( (parameters (parameter (expression (expression (expression (value - (numeric 5))) * (expression (value (numeric 3)))) + (expression (value (numeric 4)))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions03() {
    SqlParser p = parse("ABS(null)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ABS) ( (parameters (parameter (expression (value null)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions04() {
    SqlParser p = parse("BITAND(null, null)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BITAND) ( (parameters (parameter (expression (value null))) , (parameter (expression (value null)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions05() {
    SqlParser p = parse("BITAND(null, ABS(ACOS(-5 * 3+4)))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BITAND) ( (parameters (parameter (expression (value null))) , (parameter (expression (value (function (name ABS) ( (parameters (parameter (expression (value (function (name ACOS) ( (parameters (parameter (expression (expression (expression (value - (numeric 5))) * (expression (value (numeric 3)))) + (expression (value (numeric 4)))))) )))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions06() {
    SqlParser p = parse("ADD_MONTHS(DATE '1998-12-25', 1)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ADD_MONTHS) ( (parameters (parameter (expression (value (datetime DATE (expression (value (string '1998-12-25'))))))) , (parameter (expression (value (numeric 1))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions07() {
    SqlParser p = parse("EXTRACT(YEAR FROM DATE '1998-12-25')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name EXTRACT) ( (parameters (parameter YEAR FROM (expression (value (datetime DATE (expression (value (string '1998-12-25')))))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions08() {
    SqlParser p = parse("EXTRACT(TIMEZONE_REGION FROM TIMESTAMP '1999-01-01 10:00:00 -08:00')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name EXTRACT) ( (parameters (parameter TIMEZONE_REGION FROM (expression (value (datetime TIMESTAMP (expression (value (string '1999-01-01 10:00:00 -08:00')))))))) ))))", t.toStringTree(p));
  }
   
  @Test
  public void parseFunctions09() {
    SqlParser p = parse("EXTRACT(YEAR FROM INTERVAL '123-2' YEAR(3) TO MONTH)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name EXTRACT) ( (parameters (parameter YEAR FROM (expression (value (interval INTERVAL (string '123-2') YEAR ( (expression (value (numeric 3))) ) TO MONTH))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions10() {
    SqlParser p = parse("FROM_TZ(TIMESTAMP '2000-03-28 08:00:00', '3:00')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name FROM_TZ) ( (parameters (parameter (expression (value (datetime TIMESTAMP (expression (value (string '2000-03-28 08:00:00'))))))) , (parameter (expression (value (string '3:00'))))) ))))", t.toStringTree(p));
  }
 
  @Test
  public void parseFunctions11() {
    SqlParser p = parse("COLLECT(phone_numbers)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COLLECT) ( (parameters (parameter (expression (value (column (name phone_numbers)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions12() {
    SqlParser p = parse("COLLECT(warehouse_name ORDER BY warehouse_name)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COLLECT) ( (parameters (parameter (expression (value (column (name warehouse_name)))) (order_by_clause ORDER BY (expression (value (column (name warehouse_name))))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions13() {
    SqlParser p = parse("GREATEST('HARRY', 'HARRIOT', 'HAROLD')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name GREATEST) ( (parameters (parameter (expression (value (string 'HARRY')))) , (parameter (expression (value (string 'HARRIOT')))) , (parameter (expression (value (string 'HAROLD'))))) ))))", t.toStringTree(p));
  }
 
  @Test
  public void parseFunctions14() {
    SqlParser p = parse("CAST('22-OCT-1997' AS TIMESTAMP WITH LOCAL TIME ZONE)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (string '22-OCT-1997'))) AS (datatype (datetime_datatype TIMESTAMP WITH LOCAL TIME ZONE)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions15() {
    SqlParser p = parse("CAST(TO_DATE('22-Oct-1997', 'DD-Mon-YYYY') AS TIMESTAMP WITH LOCAL TIME ZONE)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '22-Oct-1997')))) , (parameter (expression (value (string 'DD-Mon-YYYY'))))) )))) AS (datatype (datetime_datatype TIMESTAMP WITH LOCAL TIME ZONE)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions16() {
    SqlParser p = parse("DECODE (warehouse_id, 1, 'Southlake', 2, 'San Francisco', 3, 'New Jersey', 4, 'Seattle', 'Non domestic')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name DECODE) ( (parameters (parameter (expression (value (column (name warehouse_id))))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (string 'Southlake')))) , (parameter (expression (value (numeric 2)))) , (parameter (expression (value (string 'San Francisco')))) , (parameter (expression (value (numeric 3)))) , (parameter (expression (value (string 'New Jersey')))) , (parameter (expression (value (numeric 4)))) , (parameter (expression (value (string 'Seattle')))) , (parameter (expression (value (string 'Non domestic'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions17() {
    SqlParser p = parse("CLUSTER_ID(km_sh_clus_sample USING *)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CLUSTER_ID) ( (parameters (parameter (expression (value (column (name km_sh_clus_sample)))) (using_clause USING *))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions18() {
    SqlParser p = parse("AVG(salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters (parameter (expression (value (column (name salary)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions19() {
    SqlParser p = parse("AVG(DISTINCT salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters DISTINCT (parameter (expression (value (column (name salary)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions20() {
    SqlParser p = parse("AVG(UNIQUE salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters UNIQUE (parameter (expression (value (column (name salary)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions21() {
    SqlParser p = parse("AVG(ALL salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters ALL (parameter (expression (value (column (name salary)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions22() {
    SqlParser p = parse("AVG(salary) OVER (PARTITION BY manager_id ORDER BY hire_date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters (parameter (expression (value (column (name salary)))))) ) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name manager_id))))) (order_by_clause ORDER BY (expression (value (column (name hire_date))))) (windowing_clause ROWS BETWEEN (expression (value (numeric 1))) PRECEDING AND (expression (value (numeric 1))) FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions23() {
    SqlParser p = parse("NEW_TIME(TO_DATE('11-10-09 01:23:45', 'MM-DD-YY HH24:MI:SS'), 'AST', 'PST')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NEW_TIME) ( (parameters (parameter (expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '11-10-09 01:23:45')))) , (parameter (expression (value (string 'MM-DD-YY HH24:MI:SS'))))) ))))) , (parameter (expression (value (string 'AST')))) , (parameter (expression (value (string 'PST'))))) ))))", t.toStringTree(p));
  }
    
  @Test
  public void parseFunctions24() {
    SqlParser p = parse("ABS(-15)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ABS) ( (parameters (parameter (expression (value - (numeric 15))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions25() {
    SqlParser p = parse("ACOS(.3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ACOS) ( (parameters (parameter (expression (value (numeric .3))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions26() {
    SqlParser p = parse("TO_CHAR(ADD_MONTHS(hire_date, 1), 'DD-MON-YYYY')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name TO_CHAR) ( (parameters (parameter (expression (value (function (name ADD_MONTHS) ( (parameters (parameter (expression (value (column (name hire_date))))) , (parameter (expression (value (numeric 1))))) ))))) , (parameter (expression (value (string 'DD-MON-YYYY'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions27() {
    SqlParser p = parse("APPENDCHILDXML(warehouse_spec, 'Warehouse/Building', XMLType('<Owner>Grandco</Owner>'))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name APPENDCHILDXML) ( (parameters (parameter (expression (value (column (name warehouse_spec))))) , (parameter (expression (value (string 'Warehouse/Building')))) , (parameter (expression (value (function (name XMLType) ( (parameters (parameter (expression (value (string '<Owner>Grandco</Owner>'))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions28() {
    SqlParser p = parse("ASCII(SUBSTR(last_name, 1, 1))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ASCII) ( (parameters (parameter (expression (value (function (name SUBSTR) ( (parameters (parameter (expression (value (column (name last_name))))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (numeric 1))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions29() {
    SqlParser p = parse("ASCIISTR('ABÄCDE')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ASCIISTR) ( (parameters (parameter (expression (value (string 'ABÄCDE'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions30() {
    SqlParser p = parse("ATAN2(.3, .2)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name ATAN2) ( (parameters (parameter (expression (value (numeric .3)))) , (parameter (expression (value (numeric .2))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions31() {
    SqlParser p = parse("AVG(salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters (parameter (expression (value (column (name salary)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions32() {
    SqlParser p = parse("AVG(salary) OVER (PARTITION BY manager_id ORDER BY hire_date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name AVG) ( (parameters (parameter (expression (value (column (name salary)))))) ) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name manager_id))))) (order_by_clause ORDER BY (expression (value (column (name hire_date))))) (windowing_clause ROWS BETWEEN (expression (value (numeric 1))) PRECEDING AND (expression (value (numeric 1))) FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions33() {
    SqlParser p = parse("BFILENAME('MEDIA_DIR', 'modem_comp_ad.gif')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BFILENAME) ( (parameters (parameter (expression (value (string 'MEDIA_DIR')))) , (parameter (expression (value (string 'modem_comp_ad.gif'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions34() {
    SqlParser p = parse("BIN_TO_NUM(1,0,1,0)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BIN_TO_NUM) ( (parameters (parameter (expression (value (numeric 1)))) , (parameter (expression (value (numeric 0)))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (numeric 0))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions35() {
    SqlParser p = parse("BIN_TO_NUM(warehouse, ground, insured)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BIN_TO_NUM) ( (parameters (parameter (expression (value (column (name warehouse))))) , (parameter (expression (value (column (name ground))))) , (parameter (expression (value (column (name insured)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions36() {
    SqlParser p = parse("BITAND(6,3)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name BITAND) ( (parameters (parameter (expression (value (numeric 6)))) , (parameter (expression (value (numeric 3))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions37() {
    SqlParser p = parse("DECODE(BITAND(order_status, 1), 1, 'Warehouse', 'PostOffice')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name DECODE) ( (parameters (parameter (expression (value (function (name BITAND) ( (parameters (parameter (expression (value (column (name order_status))))) , (parameter (expression (value (numeric 1))))) ))))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (string 'Warehouse')))) , (parameter (expression (value (string 'PostOffice'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions38() {
    SqlParser p = parse("CARDINALITY(ad_textdocs_ntab)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CARDINALITY) ( (parameters (parameter (expression (value (column (name ad_textdocs_ntab)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions39() {
    SqlParser p = parse("CAST('22-OCT-1997' AS TIMESTAMP WITH LOCAL TIME ZONE)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (string '22-OCT-1997'))) AS (datatype (datetime_datatype TIMESTAMP WITH LOCAL TIME ZONE)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions40() {
    SqlParser p = parse("CAST(TO_DATE('22-Oct-1997', 'DD-Mon-YYYY') AS TIMESTAMP WITH LOCAL TIME ZONE)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '22-Oct-1997')))) , (parameter (expression (value (string 'DD-Mon-YYYY'))))) )))) AS (datatype (datetime_datatype TIMESTAMP WITH LOCAL TIME ZONE)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions41() {
    SqlParser p = parse("CAST(ad_sourcetext AS VARCHAR2(30))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (column (name ad_sourcetext)))) AS (datatype (character_datatype VARCHAR2 ( (expression (value (numeric 30))) ))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions42() {
    SqlParser p = parse("NVL(A.attribute_str_value, ROUND(A.attribute_num_value),4)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NVL) ( (parameters (parameter (expression (value (column (table_alias (name A)) . (name attribute_str_value))))) , (parameter (expression (value (function (name ROUND) ( (parameters (parameter (expression (value (column (table_alias (name A)) . (name attribute_num_value)))))) ))))) , (parameter (expression (value (numeric 4))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions43() {
    SqlParser p = parse("DECODE(BITAND(order_status, 1), 1, 'Warehouse', 'PostOffice')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name DECODE) ( (parameters (parameter (expression (value (function (name BITAND) ( (parameters (parameter (expression (value (column (name order_status))))) , (parameter (expression (value (numeric 1))))) ))))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (string 'Warehouse')))) , (parameter (expression (value (string 'PostOffice'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions44() {
    SqlParser p = parse("CAST(s.addresses AS address_book_t)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (column (table_alias (name s)) . (name addresses)))) AS (alias (name address_book_t)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions45() {
    SqlParser p = parse("CEIL(order_total)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CEIL) ( (parameters (parameter (expression (value (column (name order_total)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions46() {
    SqlParser p = parse("CHARTOROWID('AAAFd1AAFAAAABSAA/')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CHARTOROWID) ( (parameters (parameter (expression (value (string 'AAAFd1AAFAAAABSAA/'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions47() {
    SqlParser p = parse("CHR(41378)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CHR) ( (parameters (parameter (expression (value (numeric 41378))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions48() {
    SqlParser p = parse("CHR (196 USING NCHAR_CS)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CHR) ( (parameters (parameter (expression (value (numeric 196))) (using_clause USING NCHAR_CS))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions49() {
    SqlParser p = parse("CLUSTER_PROBABILITY(km_sh_clus_sample, 2 USING *)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CLUSTER_PROBABILITY) ( (parameters (parameter (expression (value (column (name km_sh_clus_sample))))) , (parameter (expression (value (numeric 2))) (using_clause USING *))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions50() {
    SqlParser p = parse("TABLE(DBMS_DATA_MINING.GET_MODEL_DETAILS_KM('km_sh_clus_sample'))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name TABLE) ( (parameters (parameter (expression (value (function (name (pkg DBMS_DATA_MINING) . GET_MODEL_DETAILS_KM) ( (parameters (parameter (expression (value (string 'km_sh_clus_sample'))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions51() {
    SqlParser p = parse("CAST(COLLECT(p.f(aname, op, TO_CHAR(val), support, confidence)) AS Cattrs)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name COLLECT) ( (parameters (parameter (expression (value (function (name (pkg p) . f) ( (parameters (parameter (expression (value (column (name aname))))) , (parameter (expression (value (column (name op))))) , (parameter (expression (value (function (name TO_CHAR) ( (parameters (parameter (expression (value (column (name val)))))) ))))) , (parameter (expression (value (column (name support))))) , (parameter (expression (value (column (name confidence)))))) )))))) )))) AS (alias (name Cattrs)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions52() {
    SqlParser p = parse("CLUSTER_SET(km_sh_clus_sample, NULL, 0.2 USING *)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CLUSTER_SET) ( (parameters (parameter (expression (value (column (name km_sh_clus_sample))))) , (parameter (expression (value NULL))) , (parameter (expression (value (numeric 0.2))) (using_clause USING *))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions53() {
    SqlParser p = parse("CLUSTER_ID(km_sh_clus_sample USING *)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CLUSTER_ID) ( (parameters (parameter (expression (value (column (name km_sh_clus_sample)))) (using_clause USING *))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions54() {
    SqlParser p = parse("PREDICTION(DT_SH_Clas_sample COST MODEL AUTO USING cust_marital_status, education, household_size)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name PREDICTION) ( (parameters (parameter (expression (value (column (name DT_SH_Clas_sample)))) (cost_matrix_clause COST MODEL AUTO) (using_clause USING (expression (value (column (name cust_marital_status)))))) , (parameter (expression (value (column (name education))))) , (parameter (expression (value (column (name household_size)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions55() {
    SqlParser p = parse("COALESCE(0.9*list_price, min_price, 5)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COALESCE) ( (parameters (parameter (expression (expression (value (numeric 0.9))) * (expression (value (column (name list_price)))))) , (parameter (expression (value (column (name min_price))))) , (parameter (expression (value (numeric 5))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions56() {
    SqlParser p = parse("CAST(COLLECT(phone_numbers) AS phone_book_t)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name COLLECT) ( (parameters (parameter (expression (value (column (name phone_numbers)))))) )))) AS (alias (name phone_book_t)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions57() {
    SqlParser p = parse("CAST(COLLECT(warehouse_name ORDER BY warehouse_name) AS warehouse_name_t)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name COLLECT) ( (parameters (parameter (expression (value (column (name warehouse_name)))) (order_by_clause ORDER BY (expression (value (column (name warehouse_name))))))) )))) AS (alias (name warehouse_name_t)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions58() {
    SqlParser p = parse("COMPOSE( 'o' || UNISTR('\\0308') )");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COMPOSE) ( (parameters (parameter (expression (expression (value (string 'o'))) || (expression (value (function (name UNISTR) ( (parameters (parameter (expression (value (string '\\0308'))))) ))))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions59() {
    SqlParser p = parse("CONCAT(CONCAT(last_name, '''s job category is '), job_id)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CONCAT) ( (parameters (parameter (expression (value (function (name CONCAT) ( (parameters (parameter (expression (value (column (name last_name))))) , (parameter (expression (value (string '''s job category is '))))) ))))) , (parameter (expression (value (column (name job_id)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions60() {
    SqlParser p = parse("CONVERT('Ä Ê Í Õ Ø A B C D E ', 'US7ASCII', 'WE8ISO8859P1')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CONVERT) ( (parameters (parameter (expression (value (string 'Ä Ê Í Õ Ø A B C D E ')))) , (parameter (expression (value (string 'US7ASCII')))) , (parameter (expression (value (string 'WE8ISO8859P1'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions61() {
    SqlParser p = parse("CORR_S(salary, commission_pct)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CORR_S) ( (parameters (parameter (expression (value (column (name salary))))) , (parameter (expression (value (column (name commission_pct)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions62() {
    SqlParser p = parse("CORR_K(salary, commission_pct, 'COEFFICIENT')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CORR_K) ( (parameters (parameter (expression (value (column (name salary))))) , (parameter (expression (value (column (name commission_pct))))) , (parameter (expression (value (string 'COEFFICIENT'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions63() {
    SqlParser p = parse("COUNT(*)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COUNT) ( (parameters (parameter (expression (value (column (name *)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions64() {
    SqlParser p = parse("COUNT(a)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COUNT) ( (parameters (parameter (expression (value (column (name a)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions65() {
    SqlParser p = parse("COUNT(DISTINCT a)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COUNT) ( (parameters DISTINCT (parameter (expression (value (column (name a)))))) ))))", t.toStringTree(p));
  }
    
  @Test
  public void parseFunctions66() {
    SqlParser p = parse("COUNT(*) OVER (ORDER BY salary RANGE BETWEEN 50 PRECEDING AND 150 FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name COUNT) ( (parameters (parameter (expression (value (column (name *)))))) ) (over_clause OVER ( (analytic_clause (order_by_clause ORDER BY (expression (value (column (name salary))))) (windowing_clause RANGE BETWEEN (expression (value (numeric 50))) PRECEDING AND (expression (value (numeric 150))) FOLLOWING)) )))))", t.toStringTree(p));
  }
    
  @Test
  public void parseFunctions67() {
    SqlParser p = parse("CUME_DIST(15500, .05) WITHIN GROUP (ORDER BY salary, commission_pct)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CUME_DIST) ( (parameters (parameter (expression (value (numeric 15500)))) , (parameter (expression (value (numeric .05))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name salary)))) , (expression (value (column (name commission_pct))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions68() {
    SqlParser p = parse("CUME_DIST() OVER (PARTITION BY job_id ORDER BY salary)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name CUME_DIST) ( ) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name job_id))))) (order_by_clause ORDER BY (expression (value (column (name salary)))))) )))))", t.toStringTree(p));
  }
    
  @Test
  public void parseFunctions69() {
    SqlParser p = parse("UNDER_PATH(res, '/sys/schemas/OE', 1)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name UNDER_PATH) ( (parameters (parameter (expression (value (column (name res))))) , (parameter (expression (value (string '/sys/schemas/OE')))) , (parameter (expression (value (numeric 1))))) ))))", t.toStringTree(p));
  }
    
  @Test
  public void parseFunctions70() {
    SqlParser p = parse("EXISTSNODE(warehouse_spec, '/Warehouse/Docks')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name EXISTSNODE) ( (parameters (parameter (expression (value (column (name warehouse_spec))))) , (parameter (expression (value (string '/Warehouse/Docks'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions71() {
    SqlParser p = parse("EXTRACT(month FROM order_date)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name EXTRACT) ( (parameters (parameter month FROM (expression (value (column (name order_date)))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions72() {
    SqlParser p = parse("MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name salary)))))) ) (keep_clause KEEP ( DENSE_RANK FIRST (order_by_clause ORDER BY (expression (value (column (name commission_pct))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions73() {
    SqlParser p = parse("MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name MAX) ( (parameters (parameter (expression (value (column (name salary)))))) ) (keep_clause KEEP ( DENSE_RANK LAST (order_by_clause ORDER BY (expression (value (column (name commission_pct))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions74() {
    SqlParser p = parse("MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct) OVER (PARTITION BY department_id)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name salary)))))) ) (keep_clause KEEP ( DENSE_RANK FIRST (order_by_clause ORDER BY (expression (value (column (name commission_pct))))) )) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name department_id)))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions75() {
    SqlParser p = parse("MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct) OVER (PARTITION BY department_id)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name MAX) ( (parameters (parameter (expression (value (column (name salary)))))) ) (keep_clause KEEP ( DENSE_RANK LAST (order_by_clause ORDER BY (expression (value (column (name commission_pct))))) )) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name department_id)))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions76() {
    SqlParser p = parse("FIRST_VALUE(last_name) OVER (ORDER BY salary ASC ROWS UNBOUNDED PRECEDING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name FIRST_VALUE) ( (parameters (parameter (expression (value (column (name last_name)))))) ) (over_clause OVER ( (analytic_clause (order_by_clause ORDER BY (expression (value (column (name salary)))) ASC) (windowing_clause ROWS UNBOUNDED PRECEDING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions77() {
    SqlParser p = parse("FIRST_VALUE(last_name) RESPECT NULLS OVER (ORDER BY salary ASC ROWS UNBOUNDED PRECEDING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name FIRST_VALUE) ( (parameters (parameter (expression (value (column (name last_name)))))) ) (respect_clause RESPECT NULLS) (over_clause OVER ( (analytic_clause (order_by_clause ORDER BY (expression (value (column (name salary)))) ASC) (windowing_clause ROWS UNBOUNDED PRECEDING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions78() {
    SqlParser p = parse("FIRST_VALUE(last_name RESPECT NULLS) OVER (ORDER BY salary ASC ROWS UNBOUNDED PRECEDING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name FIRST_VALUE) ( (parameters (parameter (expression (value (column (name last_name)))) (respect_clause RESPECT NULLS))) ) (over_clause OVER ( (analytic_clause (order_by_clause ORDER BY (expression (value (column (name salary)))) ASC) (windowing_clause ROWS UNBOUNDED PRECEDING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions79() {
    SqlParser p = parse("FIRST_VALUE(last_name) OVER (ORDER BY salary ASC, hire_date ROWS UNBOUNDED PRECEDING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name FIRST_VALUE) ( (parameters (parameter (expression (value (column (name last_name)))))) ) (over_clause OVER ( (analytic_clause (order_by_clause ORDER BY (expression (value (column (name salary)))) ASC , (expression (value (column (name hire_date))))) (windowing_clause ROWS UNBOUNDED PRECEDING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions80() {
    SqlParser p = parse("LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY hire_date, last_name)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name LISTAGG) ( (parameters (parameter (expression (value (column (name last_name))))) , (parameter (expression (value (string '; '))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name hire_date)))) , (expression (value (column (name last_name))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions81() {
    SqlParser p = parse("LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY hire_date, last_name) OVER (PARTITION BY department_id)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name LISTAGG) ( (parameters (parameter (expression (value (column (name last_name))))) , (parameter (expression (value (string '; '))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name hire_date)))) , (expression (value (column (name last_name))))) )) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name department_id)))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions82() {
    SqlParser p = parse("NTH_VALUE(MIN(amount_sold), 2) OVER (PARTITION BY prod_id ORDER BY channel_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NTH_VALUE) ( (parameters (parameter (expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name amount_sold)))))) ))))) , (parameter (expression (value (numeric 2))))) ) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name prod_id))))) (order_by_clause ORDER BY (expression (value (column (name channel_id))))) (windowing_clause ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions83() {
    SqlParser p = parse("NTH_VALUE(MIN(amount_sold), 2) FROM FIRST OVER (PARTITION BY prod_id ORDER BY channel_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NTH_VALUE) ( (parameters (parameter (expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name amount_sold)))))) ))))) , (parameter (expression (value (numeric 2))))) ) (first_clause FROM FIRST) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name prod_id))))) (order_by_clause ORDER BY (expression (value (column (name channel_id))))) (windowing_clause ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions84() {
    SqlParser p = parse("NTH_VALUE(MIN(amount_sold), 2) RESPECT NULLs OVER (PARTITION BY prod_id ORDER BY channel_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NTH_VALUE) ( (parameters (parameter (expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name amount_sold)))))) ))))) , (parameter (expression (value (numeric 2))))) ) (respect_clause RESPECT NULLs) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name prod_id))))) (order_by_clause ORDER BY (expression (value (column (name channel_id))))) (windowing_clause ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions85() {
    SqlParser p = parse("NTH_VALUE(MIN(amount_sold), 2) FROM FIRST RESPECT NULLs OVER (PARTITION BY prod_id ORDER BY channel_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name NTH_VALUE) ( (parameters (parameter (expression (value (function (name MIN) ( (parameters (parameter (expression (value (column (name amount_sold)))))) ))))) , (parameter (expression (value (numeric 2))))) ) (first_clause FROM FIRST) (respect_clause RESPECT NULLs) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name prod_id))))) (order_by_clause ORDER BY (expression (value (column (name channel_id))))) (windowing_clause ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions86() {
    SqlParser p = parse("PERCENT_RANK(15000, .05) WITHIN GROUP (ORDER BY salary, commission_pct)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name PERCENT_RANK) ( (parameters (parameter (expression (value (numeric 15000)))) , (parameter (expression (value (numeric .05))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name salary)))) , (expression (value (column (name commission_pct))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions87() {
    SqlParser p = parse("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary DESC)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name PERCENTILE_CONT) ( (parameters (parameter (expression (value (numeric 0.5))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name salary)))) DESC) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions88() {
    SqlParser p = parse("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary DESC) OVER (PARTITION BY department_id)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name PERCENTILE_CONT) ( (parameters (parameter (expression (value (numeric 0.5))))) ) (within_clause WITHIN GROUP ( (order_by_clause ORDER BY (expression (value (column (name salary)))) DESC) )) (over_clause OVER ( (analytic_clause (query_partition_clause PARTITION BY (expression (value (column (name department_id)))))) )))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions89() {
    SqlParser p = parse("REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 1)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name REGEXP_INSTR) ( (parameters (parameter (expression (value (string '1234567890')))) , (parameter (expression (value (string '(123)(4(56)(78))')))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (numeric 1)))) , (parameter (expression (value (numeric 0)))) , (parameter (expression (value (string 'i')))) , (parameter (expression (value (numeric 1))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions90() {
    SqlParser p = parse("XMLELEMENT('Department', XMLAGG(XMLELEMENT('Employee', e.job_id||' '||e.last_name) ORDER BY last_name))");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name XMLELEMENT) ( (parameters (parameter (expression (value (string 'Department')))) , (parameter (expression (value (function (name XMLAGG) ( (parameters (parameter (expression (value (function (name XMLELEMENT) ( (parameters (parameter (expression (value (string 'Employee')))) , (parameter (expression (expression (expression (value (column (table_alias (name e)) . (name job_id)))) || (expression (value (string ' ')))) || (expression (value (column (table_alias (name e)) . (name last_name))))))) )))) (order_by_clause ORDER BY (expression (value (column (name last_name))))))) )))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions91() {
    SqlParser p = parse("XMLPARSE(CONTENT '124 <purchaseOrder poNo=\"12435\"> <customerName> Acme Enterprises</customerName> <itemNo>32987457</itemNo> </purchaseOrder>' WELLFORMED)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name XMLPARSE) ( (parameters (parameter CONTENT (expression (value (string '124 <purchaseOrder poNo=\"12435\"> <customerName> Acme Enterprises</customerName> <itemNo>32987457</itemNo> </purchaseOrder>'))) WELLFORMED)) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions92() {
    SqlParser p = parse("XMLPI(NAME 'Order analysisComp', 'imported, reconfigured, disassembled')");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name XMLPI) ( (parameters (parameter NAME (expression (value (string 'Order analysisComp')))) , (parameter (expression (value (string 'imported, reconfigured, disassembled'))))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions93() {
    SqlParser p = parse("XMLQuery('query' PASSING warehouse_spec RETURNING CONTENT)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name XMLQuery) ( (parameters (parameter (expression (value (string 'query'))) (passing_clause PASSING (expression (value (column (name warehouse_spec))))) (returning_clause RETURNING CONTENT))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions94() {
    SqlParser p = parse("XMLROOT ( XMLType('<poid>143598</poid>'), VERSION '1.0', STANDALONE YES)");
    ParseTree t = p.expression();
    assertEquals("(expression (value (function (name XMLROOT) ( (parameters (parameter (expression (value (function (name XMLType) ( (parameters (parameter (expression (value (string '<poid>143598</poid>'))))) ))))) , (parameter VERSION (expression (value (string '1.0')))) , (parameter (expression (value STANDALONE YES)))) ))))", t.toStringTree(p));
  }

  @Test
  public void parseFunctions95() {
    SqlParser p = parse("FROM_TZ(CAST(TO_DATE('1999-12-01 11:00:00', 'YYYY-MM-DD HH:MI:SS') AS TIMESTAMP), 'America/New_York') AT TIME ZONE 'America/Los_Angeles'");
    ParseTree t = p.expression();
    assertEquals("(expression (expression (value (function (name FROM_TZ) ( (parameters (parameter (expression (value (function (name CAST) ( (parameters (parameter (expression (value (function (name TO_DATE) ( (parameters (parameter (expression (value (string '1999-12-01 11:00:00')))) , (parameter (expression (value (string 'YYYY-MM-DD HH:MI:SS'))))) )))) AS (datatype (datetime_datatype TIMESTAMP)))) ))))) , (parameter (expression (value (string 'America/New_York'))))) )))) AT TIME ZONE (expression (value (string 'America/Los_Angeles'))))", t.toStringTree(p));
  }
    
  { // TODO Re-assess `object_access_expression`
    //{
    //SqlParser p = parse("tAlias.aObject.aAttribute.aMethod('aString')");
    //ParseTree t = p.expression();
    //assertEquals("(expression (object_access_expression (table_alias tAlias) . (object aObject) . (attribute aAttribute) . (method (name aMethod) ( (parameters (parameter (expression (value (string 'aString'))))) ))))", t.toStringTree(p));
    //}

    //{
    //SqlParser p = parse("TREAT(VALUE(c) AS catalog_typ).getCatalogName()");
    //ParseTree t = p.expression();
    //assertEquals("(expression (value (function (name TREAT) ( (parameters (parameter (expression (value (function (name VALUE) ( (parameters (parameter (expression (value (column (name c)))))) )))) AS (alias catalog_typ))) ) . (method (name getCatalogName) ( )))))", t.toStringTree(p));
    //}

    //{
    //SqlParser p = parse("PREDICTION_BOUNDS(glmr_sh_regr_sample,0.98 USING *).LOWER");
    //ParseTree t = p.expression();
    //assertEquals("(expression (value (function (name PREDICTION_BOUNDS) ( (parameters (parameter (expression (value (column (name glmr_sh_regr_sample))))) , (parameter (expression (value (numeric 0.98))) (using_clause USING *))) ) . (function (name LOWER)))))", t.toStringTree(p));
    //}
  }

}