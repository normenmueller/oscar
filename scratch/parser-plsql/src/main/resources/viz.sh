#!/bin/bash
antlr4='java -jar /Users/nrm/etc/lib/antlr-4.5.3-complete.jar'
grun='java org.antlr.v4.gui.TestRig'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$antlr4 $DIR/Plsql.g4 -o $DIR

javac $DIR/*.java

$grun Plsql statement $*

rm *.class
rm *.java
rm *.tokens
