package mdpm.plsql;

import org.antlr.v4.runtime.*;

public class PlsqlErrorListener extends BaseErrorListener {
  
  public static final PlsqlErrorListener INSTANCE = new PlsqlErrorListener();

  @Override
  public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) throws PlsqlException {
     throw new PlsqlException(recognizer, line, charPositionInLine, (Token) offendingSymbol, msg); 
  }

}