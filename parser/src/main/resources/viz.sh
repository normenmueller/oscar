#!/bin/bash
antlr4='java -jar /Users/nrm/etc/lib/antlr-4.5.3-complete.jar'
grun='java org.antlr.v4.gui.TestRig'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$antlr4 $DIR/Sql.g4 -o $DIR

javac $DIR/*.java

$grun Sql $*
#$grun Sql statement $*
#$grun Sql expression $*
#$grun Sql condition $*

rm *.class
rm *.java
rm *.tokens
