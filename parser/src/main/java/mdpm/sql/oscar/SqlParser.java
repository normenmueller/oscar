package mdpm.sql.oscar;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import mdpm.sql.oscar.g.SqlLexer;

public abstract class SqlParser {

  public static ParseTree parse(String e) throws SqlParserException {
    ANTLRInputStream input = new ANTLRInputStream(e);
    SqlLexer lexer = new SqlLexer(input);
    lexer.removeErrorListeners();
    lexer.addErrorListener(SqlParserErrorListener.INSTANCE);

    mdpm.sql.oscar.g.SqlParser parser = new mdpm.sql.oscar.g.SqlParser(new CommonTokenStream(lexer));
    parser.removeErrorListeners();
    parser.addErrorListener(SqlParserErrorListener.INSTANCE);

    return parser.statement();
  }

}