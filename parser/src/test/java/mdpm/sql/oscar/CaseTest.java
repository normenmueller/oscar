package mdpm.sql.oscar;

import static org.junit.Assert.*;

import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.Test;

import mdpm.sql.oscar.g.SqlParser;

public class CaseTest extends SqlParserTest {

  @Test
  public void parseExpression01() {
    SqlParser p = parse(
      "CASE WHEN x.grc_ccy IS NOT NULL THEN (\n"
    + " SELECT /*+ no_parallel(ia_i_dm_ccy) */ia_i_dm_ccy.ccy_prcsn_qty\n"
    + " FROM   ia_i_dm_ccy PARTITION(PKEY_0) /* TEMPL PARTITION_MAIN_IA */\n"
    + " WHERE  ia_i_dm_ccy.ccy = db_ety.funcl_ccy\n"
    + "        AND ia_i_dm_ccy.x_vstart <= -1 /* TEMPL pk_op_posting_prep.templ_ref_vsn I_DM_CCY */\n"
    + "        AND ia_i_dm_ccy.x_vend > -1 /* TEMPL pk_op_posting_prep.templ_ref_vsn I_DM_CCY */\n"
    + " ) END");
    ParseTree t = p.expression();
    assertEquals("(expression (case_expression CASE WHEN (condition (expression (value (column (table_alias (name x)) . (name grc_ccy)))) IS NOT NULL) THEN ( (select (simple (select_clause SELECT (select_elements (select_element (expression (value (column (table_alias (name ia_i_dm_ccy)) . (name ccy_prcsn_qty))))))) (from_clause FROM (from_elements (from_element (table (name ia_i_dm_ccy) (partition_extension_clause PARTITION ( (expression (value (column (name PKEY_0)))) )))))) (where_clause WHERE (condition (condition (condition (comparison (expression (value (column (table_alias (name ia_i_dm_ccy)) . (name ccy)))) = (expression (value (column (table_alias (name db_ety)) . (name funcl_ccy)))))) AND (condition (comparison (expression (value (column (table_alias (name ia_i_dm_ccy)) . (name x_vstart)))) <= (expression (value - (numeric 1)))))) AND (condition (comparison (expression (value (column (table_alias (name ia_i_dm_ccy)) . (name x_vend)))) > (expression (value - (numeric 1))))))))) ) END))", t.toStringTree(p));
  }

}