package mdpm.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.oscar.g.SqlParser;

public class SelectTest extends SqlParserTest {

  @Test
  public void parseSelect01() {
    SqlParser p = parse("SELECT 2 * 1.23, 3 * '2,34' FROM DUAL");
    ParseTree t = p.select();
    assertEquals("(select (subselect (query (select_clause SELECT (select_elements (select_element (expression (expression (value (numeric 2))) * (expression (value (numeric 1.23))))) , (select_element (expression (expression (value (numeric 3))) * (expression (value (string '2,34'))))))) (from_clause FROM (from_elements (from_element (table (name DUAL))))))))", t.toStringTree(p));
  }
  
  @Test
  public void parseSelect02() {
    SqlParser p = parse("SELECT COUNT(*) FROM employees WHERE TO_BINARY_FLOAT(commission_pct) != BINARY_FLOAT_NAN");
    ParseTree t = p.select();
    assertEquals("(select (subselect (query (select_clause SELECT (select_elements (select_element (expression (value (function (name COUNT) ( (parameters (parameter (expression (value (column (name *)))))) ))))))) (from_clause FROM (from_elements (from_element (table (name employees))))) (where_clause WHERE (condition (comparison (expression (value (function (name TO_BINARY_FLOAT) ( (parameters (parameter (expression (value (column (name commission_pct)))))) )))) != (expression (value (column (name BINARY_FLOAT_NAN))))))))))", t.toStringTree(p));
  }

  @Test
  public void parseSelect03() {
    SqlParser p = parse("select ins_id, ins_id_typ, ins_src_nme, ins_id as alt_ins_id, ins_id_typ as alt_ins_id_typ from rds_set_isincusip where dr = 1 group by ins_id, ins_id_typ, ins_src_nme");
    ParseTree t = p.select();
    assertEquals("(select (subselect (query (select_clause select (select_elements (select_element (expression (value (column (name ins_id))))) , (select_element (expression (value (column (name ins_id_typ))))) , (select_element (expression (value (column (name ins_src_nme))))) , (select_element (expression (value (column (name ins_id)))) as (alias (name alt_ins_id))) , (select_element (expression (value (column (name ins_id_typ)))) as (alias (name alt_ins_id_typ))))) (from_clause from (from_elements (from_element (table (name rds_set_isincusip))))) (where_clause where (condition (comparison (expression (value (column (name dr)))) = (expression (value (numeric 1)))))) (group_by_clause group by (expression (value (column (name ins_id)))) , (expression (value (column (name ins_id_typ)))) , (expression (value (column (name ins_src_nme))))))))", t.toStringTree(p));
  }

  // TODO SELECT COUNT(*) FROM employees WHERE salary < BINARY_FLOAT_INFINITY
  // TODO SELECT COUNT(*) FROM employees WHERE TO_BINARY_FLOAT(commission_pct) != BINARY_FLOAT_NAN
  // TODO SELECT COUNT(*) FROM employees WHERE salary < BINARY_DOUBLE_INFINITY
  // TODO SELECT * FROM my_table WHERE datecol > TO_DATE('02-OCT-02', 'DD-MON-YY')
  // TODO SELECT * FROM my_table WHERE datecol = TO_DATE('03-OCT-02','DD-MON-YY')
  // TODO SELECT * FROM my_table WHERE datecol = DATE '2002-10-03'
  // TODO SELECT * FROM my_table WHERE TRUNC(datecol) = DATE '2002-10-03'
  // TODO SELECT TIMESTAMP '2009-10-29 01:30:00' AT TIME ZONE 'US/Pacific' FROM DUAL
  // TODO SELECT TO_CHAR(TO_DATE('0207','MM/YY'), 'MM/YY') FROM DUAL
  // TODO SELECT TO_CHAR (TO_DATE('02#07','MM/YY'), 'MM/YY') FROM DUAL
  // TODO SELECT TO_CHAR(TO_DATE('27-OCT-98', 'DD-MON-RR'), 'YYYY') "Year" FROM DUAL
  // TODO SELECT TO_CHAR(SYSDATE, 'fmDDTH') || ' of ' || TO_CHAR(SYSDATE, 'fmMonth') || ', ' || TO_CHAR(SYSDATE, 'YYYY') "Ides" FROM DUAL
  // TODO SELECT TO_CHAR(SYSDATE, 'fmDay') || '''s Special' "Menu" FROM DUAL
  // TODO SELECT last_name employee, TO_CHAR(salary, '$99,990.99') FROM employees WHERE department_id = 80
  // TODO SELECT last_name employee, TO_CHAR(hire_date,'fmMonth DD, YYYY') hiredate FROM employees WHERE department_id = 20
  // FIXME SELECT TREAT(VALUE(c) AS catalog_typ).getCatalogName() "Catalog Type" FROM categories_tab c WHERE category_id = 90
  // TODO SELECT * FROM order_items WHERE quantity = -1 ORDER BY order_id, line_item_id, product_id
  // TODO SELECT * FROM employees WHERE -salary < 0 ORDER BY employee_id
  // TODO SELECT 'Name is ' || last_name FROM employees ORDER BY last_name
  // TODO SELECT col1 || col2 || col3 || col4 "Concatenation" FROM tab1
  // FIXME SELECT customer_id, cust_address_ntab MULTISET EXCEPT DISTINCT cust_address2_ntab multiset_except FROM customers_demo ORDER BY customer_id
  // FIXME SELECT customer_id, cust_address_ntab MULTISET INTERSECT DISTINCT cust_address2_ntab multiset_intersect FROM customers_demo ORDER BY customer_id
  // FIXME SELECT customer_id, cust_address_ntab MULTISET UNION cust_address2_ntab multiset_union FROM customers_demo ORDER BY customer_id
  // TODO SELECT TO_CHAR(ADD_MONTHS(hire_date, 1), 'DD-MON-YYYY') "Next month" FROM employees WHERE last_name = 'Baer'
  // TODO SELECT warehouse_id, warehouse_name, EXTRACTVALUE(warehouse_spec, '/Warehouse/Building/Owner') "Prop.Owner" FROM warehouses WHERE EXISTSNODE(warehouse_spec, '/Warehouse/Building/Owner') = 1
  // TODO SELECT last_name FROM employees WHERE ASCII(SUBSTR(last_name, 1, 1)) = 76 ORDER BY last_name
  // TODO SELECT ASCIISTR('ABÄCDE') FROM DUAL
  // TODO SELECT ASIN(.3) "Arc_Sine" FROM DUAL
  // TODO SELECT ATAN(.3) "Arc_Tangent" FROM DUAL
  // TODO SELECT BITAND(6,3) FROM DUAL
  // TODO SELECT BITAND( BIN_TO_NUM(1,1,0), BIN_TO_NUM(0,1,1)) "Binary" FROM DUAL
  // TODO SELECT order_id, customer_id, order_status, DECODE(BITAND(order_status, 1), 1, 'Warehouse', 'PostOffice') "Location", DECODE(BITAND(order_status, 2), 2, 'Ground', 'Air') "Method", DECODE(BITAND(order_status, 4), 4, 'Insured', 'Certified') "Receipt" FROM orders WHERE sales_rep_id = 160 ORDER BY order_id
  // TODO SELECT product_id, CARDINALITY(ad_textdocs_ntab) cardinality FROM print_media ORDER BY product_id
  // TODO SELECT CAST('22-OCT-1997' AS TIMESTAMP WITH LOCAL TIME ZONE) FROM DUAL
  // TODO SELECT CAST(TO_DATE('22-Oct-1997', 'DD-Mon-YYYY') AS TIMESTAMP WITH LOCAL TIME ZONE) FROM DUAL
  // TODO SELECT product_id, CAST(ad_sourcetext AS VARCHAR2(30)) text FROM print_media ORDER BY product_id
  // TODO SELECT s.custno, s.name, CAST(MULTISET(SELECT ca.street_address, ca.postal_code, ca.city, ca.state_province, ca.country_id FROM cust_address ca WHERE s.custno = ca.custno) AS address_book_t) FROM cust_short s ORDER BY s.custno
  // TODO SELECT CAST(s.addresses AS address_book_t) FROM states s WHERE s.state_id = 111
  // FIXME SELECT e.last_name, CAST(MULTISET(SELECT p.project_name FROM projects p WHERE p.employee_id = e.employee_id ORDER BY p.project_name) AS project_table_typ) FROM emps_short e ORDER BY e.last_name
  // TODO SELECT order_total, CEIL(order_total) FROM orders WHERE order_id = 2434
  // TODO SELECT last_name FROM employees WHERE ROWID = CHARTOROWID('AAAFd1AAFAAAABSAA/')
  // TODO SELECT CHR(67)||CHR(65)||CHR(84) "Dog" FROM DUAL
  // TODO SELECT CLUSTER_ID(km_sh_clus_sample USING *) AS clus, COUNT(*) AS cnt FROM mining_data_apply_v GROUP BY CLUSTER_ID(km_sh_clus_sample USING *) ORDER BY cnt DESC
  // TODO SELECT * FROM (SELECT cust_id, CLUSTER_PROBABILITY(km_sh_clus_sample, 2 USING *) prob FROM mining_data_apply_v ORDER BY prob DESC) WHERE ROWNUM < 11
  // TODO SELECT product_id, list_price, min_price, COALESCE(0.9*list_price, min_price, 5) "Sale" FROM product_information WHERE supplier_id = 102050 ORDER BY product_id
  // TODO SELECT CAST(COLLECT(phone_numbers) AS phone_book_t) "Income Level L Phone Book" FROM customers WHERE income_level = 'L: 300,000 and above'
  // TODO SELECT CAST(COLLECT(warehouse_name ORDER BY warehouse_name) AS warehouse_name_t) "Warehouses" FROM warehouses
  // TODO SELECT CONCAT(CONCAT(last_name, '''s job category is '), job_id) "Job" FROM employees WHERE employee_id = 152
  // TODO SELECT CONVERT('Ä Ê Í Õ Ø A B C D E ', 'US7ASCII', 'WE8ISO8859P1') FROM DUAL
  // TODO SELECT weight_class, CORR(list_price, min_price) "Correlation" FROM product_information GROUP BY weight_class ORDER BY weight_class, "Correlation"
  // TODO SELECT employee_id, job_id, TO_CHAR((SYSDATE - hire_date) YEAR TO MONTH ) "Yrs-Mns", salary, CORR(SYSDATE-hire_date, salary) OVER(PARTITION BY job_id) AS "Correlation" FROM employees WHERE department_id in (50, 80) ORDER BY job_id, employee_id
  // TODO SELECT last_name, salary, COUNT(*) OVER (ORDER BY salary RANGE BETWEEN 50 PRECEDING AND 150 FOLLOWING) AS mov_count FROM employees ORDER BY salary, last_name
  // TODO SELECT CUME_DIST(15500, .05) WITHIN GROUP (ORDER BY salary, commission_pct) "Cume-Dist of 15500" FROM employees
  // TODO SELECT job_id, last_name, salary, CUME_DIST() OVER (PARTITION BY job_id ORDER BY salary) AS cume_dist FROM employees WHERE job_id LIKE 'PU%' ORDER BY job_id, last_name, salary, cume_dist
  // TODO SELECT SESSIONTIMEZONE, CURRENT_DATE FROM DUAL
  // TODO SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL
  // TODO SELECT product_id, DECODE (warehouse_id, 1, 'Southlake', 2, 'San Francisco', 3, 'New Jersey', 4, 'Seattle', 'Non domestic') "Location" FROM inventories WHERE product_id < 1775 ORDER BY product_id, "Location"
  // TODO SELECT DENSE_RANK(15500, .05) WITHIN GROUP (ORDER BY salary DESC, commission_pct) "Dense Rank" FROM employees
  // TODO SELECT department_id, last_name, salary, DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary) DENSE_RANK FROM employees WHERE department_id = 60 ORDER BY DENSE_RANK, last_name
  // TODO SELECT PATH(1), DEPTH(2) FROM RESOURCE_VIEW WHERE UNDER_PATH(res, '/sys/schemas/OE', 1)=1 AND UNDER_PATH(res, '/sys/schemas/OE', 2)=1
  // TODO SELECT DUMP(last_name, 10, 3, 2) "ASCII" FROM employees WHERE last_name = 'Hunold' ORDER BY employee_id
  // TODO SELECT last_name, employee_id, hire_date FROM employees WHERE EXTRACT(YEAR FROM TO_DATE(hire_date, 'DD-MON-RR')) > 2007 ORDER BY hire_date
  // TODO SELECT warehouse_name, EXTRACTVALUE(e.warehouse_spec, '/Warehouse/Docks') "Docks" FROM warehouses e WHERE warehouse_spec IS NOT NULL ORDER BY warehouse_name
  // TODO SELECT * FROM (SELECT cust_id, FEATURE_VALUE(nmf_sh_sample, 3 USING *) match_quality FROM nmf_sh_sample_apply_prepared ORDER BY match_quality DESC) WHERE ROWNUM < 11
  // TODO SELECT department_id, MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct) "Worst", MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct) "Best" FROM employees GROUP BY department_id ORDER BY department_id
  // TODO SELECT last_name, department_id, salary, MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct) OVER (PARTITION BY department_id) "Worst", MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct) OVER (PARTITION BY department_id) "Best" FROM employees ORDER BY department_id, salary, last_name
  // TODO SELECT department_id, last_name, salary, FIRST_VALUE(last_name) OVER (ORDER BY salary ASC ROWS UNBOUNDED PRECEDING) AS lowest_sal FROM (SELECT * FROM employees WHERE department_id = 90 ORDER BY employee_id) ORDER BY last_name
  // TODO SELECT department_id, last_name, salary, FIRST_VALUE(last_name) OVER (ORDER BY salary ASC ROWS UNBOUNDED PRECEDING) AS fv FROM (SELECT * FROM employees WHERE department_id = 90 ORDER by employee_id DESC) ORDER BY last_name
  // TODO SELECT hire_date, last_name, salary, LAG(salary, 1, 0 ) OVER (ORDER BY hire_date) AS prev_sal FROM employees WHERE job_id = 'PU_CLERK' ORDER BY hire_date
  // TODO SELECT last_name, hire_date, TO_CHAR(ADD_MONTHS(LAST_DAY(hire_date), 5)) "Eval Date" FROM employees ORDER BY last_name, hire_date
  // TODO SELECT e.last_name, NULLIF(j.job_id, e.job_id) "Old Job ID" FROM employees e, job_history j WHERE e.employee_id = j.employee_id ORDER BY last_name, "Old Job ID"
  // TODO SELECT XMLELEMENT("Department", XMLAGG(XMLELEMENT("Employee", e.job_id||' '||e.last_name) ORDER BY last_name)) as "Dept_list" FROM employees e WHERE e.department_id = 30
  // TODO SELECT e1.last_name FROM employees e1 WHERE f( CURSOR(SELECT e2.hire_date FROM employees e2 WHERE e1.employee_id = e2.manager_id), e1.hire_date) = 1 ORDER BY last_name
  // TODO SELECT * FROM employees WHERE job_id IN ('PU_CLERK','SH_CLERK') ORDER BY employee_id
  // TODO SELECT * FROM employees WHERE salary IN (SELECT salary FROM employees WHERE department_id =30) ORDER BY employee_id
  // TODO SELECT * FROM employees WHERE salary NOT IN (SELECT salary FROM employees WHERE department_id = 30) ORDER BY employee_id
  // TODO SELECT * FROM employees WHERE job_id NOT IN ('PU_CLERK', 'SH_CLERK') ORDER BY employee_id
  // TODO SELECT * FROM persons p WHERE VALUE(p) IS OF TYPE (employee_t)
  // TODO SELECT * FROM persons p WHERE VALUE(p) IS OF (ONLY part_time_emp_t)
  // TODO SELECT employee_id, last_name, manager_id FROM employees CONNECT BY PRIOR employee_id = manager_id
  // TODO SELECT last_name, employee_id, manager_id, LEVEL FROM employees START WITH employee_id = 100 CONNECT BY PRIOR employee_id = manager_id ORDER SIBLINGS BY last_name
  // TODO SELECT last_name "Employee", CONNECT_BY_ISCYCLE "Cycle", LEVEL, SYS_CONNECT_BY_PATH(last_name, '/') "Path" FROM employees WHERE level <= 3 AND department_id = 80 START WITH last_name = 'King' CONNECT BY NOCYCLE PRIOR employee_id = manager_id AND LEVEL <= 4 ORDER BY "Employee", "Cycle", LEVEL, "Path"
  // TODO SELECT LTRIM(SYS_CONNECT_BY_PATH (warehouse_id,','),',') FROM (SELECT ROWNUM r, warehouse_id FROM warehouses) WHERE CONNECT_BY_ISLEAF = 1 START WITH r = 1 CONNECT BY r = PRIOR r + 1 ORDER BY warehouse_id
  // TODO SELECT last_name "Employee", CONNECT_BY_ROOT last_name "Manager", LEVEL-1 "Pathlen", SYS_CONNECT_BY_PATH(last_name, '/') "Path" FROM employees WHERE LEVEL > 1 and department_id = 110 CONNECT BY PRIOR employee_id = manager_id ORDER BY "Employee", "Manager", "Pathlen", "Path"
  // TODO SELECT name, SUM(salary) "Total_Salary" FROM ( SELECT CONNECT_BY_ROOT last_name as name, Salary FROM employees WHERE department_id = 110 CONNECT BY PRIOR employee_id = manager_id) GROUP BY name ORDER BY name, "Total_Salary"
  // TODO SELECT 3 FROM DUAL INTERSECT SELECT 3f FROM DUAL
  // TODO SELECT TO_BINARY_FLOAT(3) FROM DUAL INTERSECT SELECT 3f FROM DUAL
  // TODO SELECT '3' FROM DUAL INTERSECT SELECT 3f FROM DUAL
  // TODO SELECT location_id, department_name "Department", TO_CHAR(NULL) "Warehouse" FROM departments UNION SELECT location_id, TO_CHAR(NULL) "Department", warehouse_name FROM warehouses
  // TODO SELECT product_id FROM order_items UNION SELECT product_id FROM inventories ORDER BY product_id
  // TODO SELECT location_id FROM locations UNION ALL SELECT location_id FROM departments ORDER BY location_id
  // TODO SELECT product_id FROM inventories INTERSECT SELECT product_id FROM order_items ORDER BY product_id
  // TODO SELECT product_id FROM inventories MINUS SELECT product_id FROM order_items ORDER BY product_id
  // TODO SELECT e1.employee_id, e1.manager_id, e2.employee_id FROM employees e1, employees e2 WHERE e1.manager_id(+) = e2.employee_id ORDER BY e1.employee_id, e1.manager_id, e2.employee_id
  // TODO SELECT LTRIM(SYS_CONNECT_BY_PATH (warehouse_id,','),',') FROM (SELECT ROWNUM r, warehouse_id FROM warehouses) WHERE CONNECT_BY_ISLEAF = 1 START WITH r = 1 CONNECT BY r = PRIOR r + 1 ORDER BY warehouse_id
  // TODO SELECT last_name "Employee", CONNECT_BY_ROOT last_name "Manager", LEVEL-1 "Pathlen", SYS_CONNECT_BY_PATH(last_name, '/') "Path" FROM employees WHERE LEVEL > 1 and department_id = 110 CONNECT BY PRIOR employee_id = manager_id ORDER BY "Employee", "Manager", "Pathlen", "Path"

}