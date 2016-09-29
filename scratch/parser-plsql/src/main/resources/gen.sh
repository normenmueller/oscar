#!/bin/bash
antlr4='java -jar /Users/nrm/etc/lib/antlr-4.5.3-complete.jar'
grun='java org.antlr.v4.gui.TestRig'

$antlr4 -visitor Plsql.g4 -o ../java/mdpm/plsql/g/ -package mdpm.plsql.g
