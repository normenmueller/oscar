package mdpm.oscar;

import java.util.concurrent.CancellationException;
import org.antlr.v4.runtime.*;

public class SqlParserException extends CancellationException {

  private static final long serialVersionUID = 1L;

  private final Recognizer<?,?> recognizer;
  private final int line;
  private final int column;
  private final Token symbol;
  private final String description;

  public SqlParserException(Recognizer<?,?> recognizer, int line, int column, Token symbol, String description) {
    this.recognizer = recognizer;
    this.line = line;
    this.column = column;
    this.symbol = symbol;
    this.description = description;
  }

  @Override
  public String getMessage() {
    return "line "+line+":"+column+": "+description;
  }
  
  public String getUnderlinedMessage() {
    return underlineError(recognizer, symbol, line, column);
  }

  private String underlineError(Recognizer<?, ?> recognizer, Token offendingToken, int line, int charPositionInLine) {
    StringBuilder buf = new StringBuilder();
    CommonTokenStream tokens = (CommonTokenStream)recognizer.getInputStream();
    String input = tokens.getTokenSource().getInputStream().toString();
    String[] lines = input.split("\n");
    String errorLine = lines[line - 1];

    buf.append(errorLine);
    buf.append("\n");
    
    for (int i=0; i<charPositionInLine; i++)
      buf.append(" ");

    int start = offendingToken.getStartIndex();
    int stop = offendingToken.getStopIndex();
    if ( start>=0 && stop>=0 ) {
      for (int i=start; i<=stop; i++)
        buf.append("^");
    }
    
    return buf.toString();
  }

}
