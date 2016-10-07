package mdpm.oscar;

import org.antlr.v4.runtime.*;

public class SqlParserErrorListener extends BaseErrorListener {
  
  public static final SqlParserErrorListener INSTANCE = new SqlParserErrorListener();

  @Override
  public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) throws SqlParserException {
     throw new SqlParserException(recognizer, line, charPositionInLine, (Token) offendingSymbol, msg); 
  }

}
