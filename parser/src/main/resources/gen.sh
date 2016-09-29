#!/bin/bash
antlr4='java -jar /Users/nrm/etc/lib/antlr-4.5.3-complete.jar'
grun='java org.antlr.v4.gui.TestRig'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$antlr4 -visitor $DIR/Sql.g4 -o ../java/mdpm/sql/oscar/g/ -package mdpm.sql.oscar.g
