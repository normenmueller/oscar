package mdpm.sql.oscar;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
//import java.nio.file.Files;
//import java.nio.file.Paths;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import mdpm.sql.oscar.g.SqlLexer;
import mdpm.sql.oscar.g.SqlParser;

public abstract class SqlParserTest {

  protected SqlParser parse(String e) throws SqlParserException {
    SqlLexer lexer = new SqlLexer(new ANTLRInputStream(e));
    lexer.removeErrorListeners();
    lexer.addErrorListener(SqlParserErrorListener.INSTANCE);

    SqlParser parser = new SqlParser(new CommonTokenStream(lexer));
    parser.removeErrorListeners();
    parser.addErrorListener(SqlParserErrorListener.INSTANCE);
   
    return parser;
  }

  protected String slurp(String f) throws IOException {
    //return Files.lines(Paths.get(f)).collect(Collectors.toList());
    //return new String(Files.readAllBytes(Paths.get(f)));
    StringBuilder lines = new StringBuilder(); 
    BufferedReader br = new BufferedReader(new FileReader(f));
    try {
      String line = br.readLine();

      while (line != null) {
        lines.append(line).append("\n");
        line = br.readLine();
      }
    } finally {
      br.close();
    }
    return lines.toString();
  }

}