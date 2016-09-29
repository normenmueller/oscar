package mdpm.plsql;

import java.util.HashSet;
import java.util.Set;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import mdpm.plsql.g.PlsqlLexer;
import mdpm.plsql.g.PlsqlParser;

public abstract class PlsqlUtil {

  public static ParseTree parse(String e) throws PlsqlException {
    PlsqlLexer lexer = new PlsqlLexer(new ANTLRInputStream(e));
    lexer.removeErrorListeners();
    lexer.addErrorListener(PlsqlErrorListener.INSTANCE);

    PlsqlParser parser = new PlsqlParser(new CommonTokenStream(lexer));
    parser.removeErrorListeners();
    parser.addErrorListener(PlsqlErrorListener.INSTANCE);
   
    return parser.statement();
  }
  
  public static Set<String> entities(ParseTree tree) {
    final Set<String> es = new HashSet<String>();
    return es;
  }

}