/*******************************************************************************\
 * Name:              Oracle(c) SQL 11g R2 grammar                             *
 * version:           0.1.0                                                    *
 * synopsis:          n/a                                                      *
 * description:       Please see README.md                                     *
 * homepage:          https://github.com/normenmueller/parser-sql              *
 * license:           Please see LICENSE                                       *
 * author:            Normen Müller                                            *
 * maintainer:        normen.mueller@gmail.com                                 *
 * copyright:         2016, Normen Müller                                      *
 * category:          Database                                                 *
\*******************************************************************************/
grammar Sql;

// Parser {{{1
statement
  : select for_update_clause?
  ;

// Select {{{2
select
  : '(' select ')'
  | simple order_by_clause?
  | compound order_by_clause?
  ;

simple
  : '(' simple ')'
  | factoring_clause? select_clause from_clause where_clause? hierarchical_query_clause? group_by_clause? model_clause? 
  ;

compound
  : '(' compound ')'
  | (simple|'('compound')') ((UNION ALL?|INTERSECT|MINUS) (simple|'('compound')'))+
  ;

// Subquery factoring clause {{{3
factoring_clause
  : WITH factoring_element (',' factoring_element)*
  ;

factoring_element
  : name["simple"] ('(' column_alias (',' column_alias)* ')')? AS '(' select ')' search_clause? cycle_clause?
  ;

search_clause
  : SEARCH (DEPTH|BREADTH) FIRST BY search_elements SET column_alias
  ;

search_elements
  : search_element (',' search_element)*
  ;

search_element
  : column_alias (ASC|DESC)? (NULLS (FIRST|LAST))?
  ;

cycle_clause
  : CYCLE cycle_elements SET column_alias TO expression DEFAULT expression
  ;

cycle_elements
  : cycle_element (',' cycle_element)*
  ;

cycle_element
  : column_alias
  ;

// Select clause {{{3
select_clause
  : SELECT ((DISTINCT|UNIQUE)|ALL)? select_elements
  ;

select_elements
  : select_element (',' select_element)*
  ; 

select_element
  : expression (AS? column_alias)?
  | '(' select ')' (AS? column_alias)?
  ;

// From clause {{{3
from_clause
  : FROM from_elements
  ;

from_elements
  : from_element (',' from_element)*
  ;

from_element
  : table
  | join_clause
  | '(' join_clause ')'
  ;

// Table reference {{{4
// v1 {{{5
//table
//  : (ONLY '(' query_table_expression ')'|query_table_expression (pivot_clause|unpivot_clause)?) flashback_query_clause? table_alias?
//  ;
//
//query_table_expression
//  : (name["simple"]|(schema '.')? table_alias (partition_extension_clause|'@' dblink)) sample_clause?
//  | '(' subquery (WITH (READ ONLY|CHECK OPTION) (CONSTRAINT name["simple"])?)? ')'
//  | table_collection_expression
//  ;
// v2 {{{5
//table
//  : ( (name["simple"]|(schema '.')? table_alias (partition_extension_clause|'@' dblink)) sample_clause?
//    | '(' select (WITH (READ ONLY|CHECK OPTION) (CONSTRAINT name["simple"])?)? ')'
//    | table_collection_expression
//    ) (pivot_clause|unpivot_clause)? flashback_query_clause? table_alias?
//  ;
// v3 {{{5
table
  : ONLY '(' 
    ( name["simple"]
    | (schema '.')? name["simple"] (partition_extension_clause|'@' dblink)? sample_clause?
    | '(' select (WITH (READ ONLY|CHECK OPTION) (CONSTRAINT name["simple"])?)? ')'
    | table_collection_expression
    ) ')' flashback_query_clause? table_alias?
  | ( name["simple"]
    | (schema '.')? name["simple"] (partition_extension_clause|'@' dblink)? sample_clause?
    | '(' select (WITH (READ ONLY|CHECK OPTION) (CONSTRAINT name["simple"])?)? ')'
    | table_collection_expression
    ) (pivot_clause|unpivot_clause)? flashback_query_clause? table_alias?
  ;

// Pivot clause {{{5
pivot_clause
  : PIVOT XML? '(' pivot_elements pivot_for_clause pivot_in_clause ')'
  ;

pivot_elements
  : pivot_element (',' pivot_element)*
  ;

pivot_element
  : function (AS? column_alias)?
  ;

pivot_for_clause
  : FOR (column|'(' column (',' column)* ')')
  ;

pivot_in_clause
  : IN '(' select ')'
  | IN '(' expression (AS? column_alias)? (',' expression (AS? column_alias)?)* ')'
  ;

unpivot_clause
  : UNPIVOT ((INCLUDE|EXCLUDE) NULLS)? '(' (column|'(' column (',' column)* ')') pivot_for_clause unpivot_in_clause ')'
  ;

unpivot_in_clause
  : IN '(' expression (AS? column_alias)? (',' expression (AS? column_alias)?)* ')'
  ;

flashback_query_clause
  : VERSIONS BETWEEN (SCN|TIMESTAMP) expression
  | AS OF (SCN|TIMESTAMP|SNAPSHOT) expression
  ;

sample_clause
  : SAMPLE BLOCK? '(' expression ')' (SEED expression)?
  ;

partition_extension_clause
  : (SUBPARTITION|PARTITION) FOR? '(' expression (',' expression)* ')'
  ;

table_collection_expression
  : (TABLE|THE) '(' (select|expression) ')' ('(' '+' ')')?
  ;

// Join clause {{{4
join_clause
  : table (inner_cross_join_clause|outer_join_clause)+
  ;

inner_cross_join_clause
  : (CROSS|NATURAL INNER?) JOIN table
  | INNER? JOIN table (ON condition|USING '(' expression ')')
  ;

outer_join_clause
  : query_partition_clause? NATURAL? outer_join_type JOIN table query_partition_clause? (ON condition|USING expression)?
  ;

outer_join_type
  : (FULL|LEFT|RIGHT) OUTER?
  ;

// Where clause {{{3
where_clause
  : WHERE condition
  ;

// Hierarchical query clause {{{3
hierarchical_query_clause
  : CONNECT BY NOCYCLE? condition (START WITH condition)?
  | START WITH condition CONNECT BY NOCYCLE? condition
  ;

// Group by clause {{{3
group_by_clause
  : GROUP BY (grouping_sets_clause|rollup_cube_clause|expression) (',' (grouping_sets_clause|rollup_cube_clause|expression))* (HAVING condition)?
  ;

rollup_cube_clause
  : (ROLLUP|CUBE) '(' expression (',' expression)* ')'
  ;

grouping_sets_clause
  : GROUPING SETS '(' (rollup_cube_clause|(expression (',' expression)*)|('('expression (',' expression)*')')) (',' (rollup_cube_clause|(expression (',' expression)*)|('('expression (',' expression)*')')))* ')'
  ;

// Model clause {{{3
model_clause
  : MODEL cell_reference_options? return_rows_clause? reference_model* main_model
  ;

cell_reference_options
  : ((IGNORE|KEEP) NAV) (UNIQUE (DIMENSION|SINGLE REFERENCE))?
  ;

return_rows_clause
  : RETURN (UPDATED|ALL) ROWS
  ;

reference_model
  : REFERENCE name["simple"] ON '(' select ')' model_column_clauses cell_reference_options?
  ;

main_model
  : (MAIN name["simple"])? model_column_clauses cell_reference_options? model_rules_clause?
  ;

model_column_clauses
  : (PARTITION BY '(' expression column_alias? (',' expression column_alias?)* ')')? DIMENSION BY '(' expression column_alias? (',' expression column_alias?)* ')' MEASURES '(' expression column_alias? (',' expression column_alias?)* ')'
  ;

model_rules_clause
  : RULES ((UPDATE|UPSERT ALL?))? ((AUTOMATIC|SEQUENTIAL) ORDER)? model_iterate_clause? '(' ((UPDATE|UPSERT ALL?)? cell_assignment order_by_clause? '=' expression (',' (UPDATE|UPSERT ALL?)? cell_assignment order_by_clause? '=' expression)*)? ')'
  ;

model_iterate_clause
  : ITERATE '(' numeric ')' (UNTIL '(' condition ')')?
  ;

cell_assignment
  : column '[' (expression|condition|single_column_for_loop) (',' (expression|condition|single_column_for_loop))* ']'
  | column '[' multi_column_for_loop ']'
  ;

single_column_for_loop
  : FOR column (IN '(' select|expression (',' select|expression)* ')'|(LIKE expression)? FROM expression TO expression (INCREMENT|DECREMENT) expression)
  ;

multi_column_for_loop
  : FOR '(' column (',' column)* ')' IN '(' select|expression (',' select|expression)* ')'
  ;

for_update_clause
  : FOR UPDATE (OF column (',' column)*)? (NOWAIT|WAIT numeric|SKIP_ LOCKED)?
  ;

// Datatypes {{{2
datatype
  : character_datatype
  | number_datatype
  | long_and_raw_datatype
  | datetime_datatype
  | large_object_datatype
  | rowid_datatype
  | special_datatype
  ;

character_datatype
  : CHAR ('(' expression (BYTE | CHAR)? ')')?
  | NCHAR ('(' expression ')')?
  | CHARACTER '(' expression ')'
  | NATIONAL (CHARACTER | CHAR) '(' expression ')'
  | CHARACTER VARYING ('(' expression ')')
  | VARCHAR2 '(' expression  (BYTE | CHAR)? ')'
  | (CHAR | NCHAR ) VARYING ('(' expression ')')
  | NVARCHAR2 '(' expression ')'
  | NATIONAL (CHARACTER | CHAR) VARYING '(' expression ')'
  | VARCHAR '(' expression ')'
  ;

number_datatype
  : (NUMBER | NUMERIC | DECIMAL | DEC) ('(' expression (',' expression)? ')')?
  | FLOAT ('(' expression ')')?
  | INTEGER | INT | SMALLINT 
  | DOUBLE PRECISION?
  | REAL
  | BINARY_FLOAT
  | BINARY_DOUBLE
  ;

long_and_raw_datatype
  : LONG RAW?
  | RAW '(' expression ')'
  ;

datetime_datatype
  : DATE
  | TIMESTAMP ('(' expression ')')? (WITH LOCAL? TIME ZONE)?
  | INTERVAL YEAR ('(' expression ')')? TO MONTH
  | INTERVAL DAY ('(' expression ')')? TO SECOND ('(' expression ')')?
  ;

large_object_datatype
  : BLOB
  | CLOB
  | NCLOB
  | BFILE
  ;

rowid_datatype
  : ROWID
  | UROWID ('(' expression ')')?
  ;

special_datatype
  : SYS '.' (ANYDATA | ANYTYPE | ANYDATASET)
  | XMLTYPE | URITYPE
  | SDO_GEOMETRY
  | SDO_TOPO_GEOMETRY
  | SDO_GEORASTER
  | ORDAUDIO
  | ORDIMAGE
  | ORDVIDEO
  | ORDDOC
  | ORDDICOM
  | SI_STILLIMAGE
  | SI_AVERAGECOLOR
  | SI_POSITIONALCOLOR
  | SI_COLORHISTOGRAM
  | SI_TEXTURE
  | SI_FEATURELIST
  | SI_COLOR
  ;

// Expressions {{{2
expression
  : PRIOR expression
  | CONNECT_BY_ROOT expression
  | CURSOR '(' select ')'
  | NEW (schema '.')? type '(' parameters? ')'
  | case_expression
  // TODO | object_access_expression
  //| ('-')? '(' expression (',' expression)* ')' //OR: | '(' expression ')'
  | '(' expression (',' expression)* ')' //OR: | '(' expression ')'
  | expression '(' '+' ')'
  | expression AT (LOCAL|TIME ZONE expression)
  | expression ('*'|'/') expression
  | expression ('+'|'-'|'||') expression
  | value
  ;

// TODO object_access_expression
// TODO   : ( table_alias '.' object '.' | '(' expression ')' '.') (attribute ('.' attribute)* '.')? method 
// TODO   ;
// TODO 
// TODO method
// TODO   : name["any"] '(' parameters? ')'
// TODO   ;

// Values {{{3
value
  : string["any"]
  | ('+' | '-')? numeric 
  | datetime
  | interval
  | sequence
  | ('-')? cell_assignment
  | ('-')? column
  | ('-')? function
  | '('select')'
  | ANY
  | DBTIMEZONE
  | MAXVALUE | MINVALUE
  | NULL
  | SESSIONTIMEZONE | STANDALONE (YES|NO VALUE?)
  ;

// String {{{4
string[String k]
  : {$k.equals("any") || $k.equals("simple")}? SIMPLE_STRING_LITERAL
  | {$k.equals("any") || $k.equals("quoted")}? QUOTED_STRING_LITERAL
  | {$k.equals("any") || $k.equals("national")}? NATIONAL_STRING_LITERAL 
  ;

// Numeric {{{4
numeric
  : INTEGER_LITERAL
  | FLOAT_LITERAL
  | SCIENTIFIC_LITERAL
  ;

// Datetime {{{4
datetime
  : DATE expression
  | TIMESTAMP (expression (AT TIME ZONE expression)? | WITH LOCAL TIME ZONE)
  ;

// Interval {{{4
interval
  : INTERVAL string["simple"] (YEAR|MONTH) ('(' expression ')')? (TO (YEAR|MONTH))?
  | INTERVAL string["simple"] ((DAY|HOUR|MINUTE)  ('(' expression ')')? | (SECOND ('(' expression (',' expression)? ')')?)) (TO (DAY|HOUR|MINUTE|(SECOND ('(' expression ')')?)))?
  ;

// Sequence reference {{{4
sequence
  : (schema '.')? name["simple"] '.' (CURRVAL|NEXTVAL) ('@' dblink)?
  ;

// Column reference {{{4
column
//: ((schema '.')? table_alias '.')? name["simple"]
  : ((schema '.')? table_alias '.')? name["any"] //(~'(')
  ;

// Function {{{4
function
  : name["function"] ('(' parameters? ')')? first_clause? respect_clause? keep_clause? within_clause? over_clause?
  //: name["function"] ('(' parameters? ')' ('.' (method|function))?)? first_clause? respect_clause? keep_clause? within_clause? over_clause?
  ;

parameters
  : (name["any"] '=>')? parameter (',' (name["any"] '=>')? parameter)* 
  ;

parameter
  : (YEAR|MONTH|DAY|HOUR|MINUTE|SECOND|TIMEZONE_HOUR|TIMEZONE_MINUTE|TIMEZONE_REGION|TIMEZONE_ABBR|(LEADING|TRAILING|BOTH)? expression) FROM expression
  | (NAME|EVALNAME) expression
  | (DOCUMENT|CONTENT) expression WELLFORMED?
  | VERSION (NO VALUE|expression)
  | (DISTINCT|UNIQUE|ALL)? expression (AS (datatype|alias)|order_by_clause|respect_clause|passing_clause|passing_clause? returning_clause|cost_matrix_clause? using_clause)?
  ;

first_clause
  : FROM (FIRST|LAST)
  ;

respect_clause
  : (RESPECT | IGNORE) NULLS
  ;

passing_clause
  : PASSING (BY VALUE)? expression (AS alias)? (',' expression (AS alias)?)* 
  ;

returning_clause
  : RETURNING CONTENT (NULL ON EMPTY)?
  ;

cost_matrix_clause
  : COST MODEL AUTO?
  | COST '(' expression (',' expression)* ')' VALUES '(' expression (',' expression)* ')'
  ;

using_clause
  : USING (CHAR_CS | NCHAR_CS | ((schema '.')? table_alias '.')? '*' | expression (AS alias)?)
  ;

within_clause
  : WITHIN GROUP '(' order_by_clause ')'
  ;
  
keep_clause
  : KEEP '(' DENSE_RANK (FIRST|LAST) order_by_clause ')' //(OVER '(' analytic_clause? ')')?
  ;
  
over_clause
  : OVER '(' analytic_clause? ')'
  ;

analytic_clause
  : query_partition_clause
  | order_by_clause (windowing_clause)?
  | query_partition_clause order_by_clause (windowing_clause)?
  ;

windowing_clause
  : (ROWS|RANGE) BETWEEN (UNBOUNDED PRECEDING|CURRENT ROW|expression (PRECEDING|FOLLOWING)) AND (UNBOUNDED FOLLOWING|CURRENT ROW|expression (PRECEDING|FOLLOWING))
  | (ROWS|RANGE) UNBOUNDED PRECEDING
  | (ROWS|RANGE) CURRENT ROW
  | (ROWS|RANGE) expression PRECEDING 
  ;

// Case {{{3
case_expression
  : CASE expression (WHEN (comparison|value) THEN (select|expression))+ (ELSE (select|expression))? END
  // TODO re-assess                   ^^^^^
  // TDOD Here `value` is primarily used for for
  // TODO `case ... when (select ...) then ...`
  | CASE (WHEN condition THEN ('('select')'|expression))+ (ELSE ('('select')'|expression))? END
  ;

// Conditions {{{2
// TODO Re-assess: always `('('select')'|expression)` rather than just `expression`?
condition
  : '(' condition ')'
  | LNNVL '(' condition ')'
  | EXISTS '(' select ')'
  | REGEXP_LIKE '(' expression ',' expression (',' expression)? ')'
  | comparison
  | expression NOT? BETWEEN expression AND expression
  | expression NOT? IN ('(' select ')'| expression)
  | expression NOT? (MEMBER|SUBMULTISET) OF? table_alias
  | expression IS NOT? (ANY|NAN|INFINITE|NULL|PRESENT|ASET|EMPTY|/*OF datatype*/)
  | expression NOT? (LIKE|LIKEC|LIKE2|LIKE4) expression (ESCAPE expression)?
  | NOT condition
  | condition AND condition
  | condition OR condition
  ;

// Comparisons {{{3
comparison
  : '(' comparison ')'
  | expression ('='|'!='|'^='|'<>'|'>'|'<'|'>='|'<=') (ANY|SOME|ALL)? '('(select|expression)')' 
  | expression ('='|'!='|'^='|'<>'|'>'|'<'|'>='|'<=') expression 
  ;

// Commons {{{2
query_partition_clause
  : PARTITION BY expression (',' expression)*
  | PARTITION BY '(' expression (',' expression)* ')'
  ;

order_by_clause
  : ORDER SIBLINGS? BY expression (ASC|DESC)? (NULLS (FIRST|LAST))? (',' expression (ASC|DESC)? (NULLS (FIRST|LAST))?)*
  ;

//alias        : ID ;
alias        : name["any"] ;
//table_alias  : ID ;
table_alias  : name["any"] ;
//column_alias : ID ;
column_alias : name["any"] ;

attribute    : ID ;
connection   : ID ;
database     : ID ;
domain       : ID ;
model        : ID ;
object       : ID ;
package_name : ID ;
schema       : ID ;
type         : ID ;

dblink
  : database ('.' domain)* ('@' connection)?
  ;

// Names {{{3
name[String k]
  : {$k.equals("any") || $k.equals("function")}?
      ABS | ACOS | ASIN | ATAN | ATAN2 | ASCII | ADD_MONTHS | ASCIISTR | APPENDCHILDXML | AVG
    | BITAND | BIN_TO_NUM | BFILENAME
    | CEIL | COS | COSH | CHR | CONCAT | CURRENT_DATE | CURRENT_TIMESTAMP | CAST | CHARTOROWID | COMPOSE | CONVERT | CARDINALITY | COLLECT | CLUSTER_ID | CLUSTER_PROBABILITY | CLUSTER_SET | COALESCE | CORR_S | CORR_K | COUNT | COVAR_POP | COVAR_SAMP | CUME_DIST | COLUMN_VALUE
    | DBTIMEZONE | DECOMPOSE | DELETEXML | DEPTH | DECODE | DUMP | DENSE_RANK 
    | EXP | EXTRACT | EMPTY_BLOB | EMPTY_CLOB | EXISTSNODE | EXTRACTVALUE | EQUALS_PATH
    | FLOOR | FROM_TZ | FEATURE_ID | FEATURE_SET | FEATURE_VALUE | FIRST | FIRST_VALUE
    | GREATEST | GROUP_ID | GROUPING | GROUPING_ID 
    | HEXTORAW 
    | INITCAP | INSTR | INSTRB | INSTRC | INSTR2 | INSTR4 | INSERTCHILDXML | INSERTCHILDXMLAFTER | INSERTCHILDXMLBEFORE | INSERTXMLAFTER | INSERTXMLBEFORE 
    | LAG | LN | LOG | LOWER | LPAD | LTRIM | LENGTH | LENGTHB | LENGTHC | LENGTH2 | LENGTH4 | LAST_DAY | LOCALTIMESTAMP | LEAST | LAST | LISTAGG | LEAD
    | MOD | MONTHS_BETWEEN | MAX | MEDIAN | MIN
    | NANVL | NCHR | NLS_INITCAP | NLS_LOWER | NLS_UPPER | NLSSORT | NLS_CHARSET_DECL_LEN | NLS_CHARSET_ID | NLS_CHARSET_NAME | NEW_TIME | NEXT_DAY | NUMTODSINTERVAL | NUMTOYMINTERVAL | NUMTODSINTERVAL | NUMTOYMINTERVAL | NANVL | NULLIF | NVL| NVL2 | NTH_VALUE
    | ORA_DST_AFFECTED | ORA_DST_CONVERT | ORA_DST_ERROR | ORA_HASH 
    | POWER | POWERMULTISET | POWERMULTISET_BY_CARDINALITY | PREDICTION | PREDICTION_BOUNDS | PREDICTION_COST | PREDICTION_DETAILS | PREDICTION_PROBABILITY | PREDICTION_SET | PATH | PERCENT_RANK | PERCENTILE_CONT | PERCENTILE_DISC | RANK 
    | REMAINDER | ROUND | REGEXP_REPLACE | REGEXP_SUBSTR | REPLACE | RPAD | RTRIM | REGEXP_COUNT | REGEXP_INSTR | RAWTOHEX | RAWTONHEX | ROWIDTOCHAR | ROWIDTONCHAR | REGR_SLOPE | REGR_INTERCEPT | REGR_COUNT | REGR_R2 | REGR_AVGX | REGR_AVGY | REGR_SXX | REGR_SYY | REGR_SXY | ROW_NUMBER | RATIO_TO_REPORT | REVERSE
    | SIGN | SIN | SINH | SQRT | SOUNDEX | SUBSTR| SUBSTRB | SUBSTRC | SUBSTR2 | SUBSTR4 | SESSIONTIMEZONE | SYS_EXTRACT_UTC | SYSDATE | SYSTIMESTAMP | SCN_TO_TIMESTAMP | SET | SYS_CONNECT_BY_PATH | SYS_DBURIGEN | SYS_XMLAGG | SYS_XMLGEN | SYS_CONTEXT | SYS_GUID | SYS_TYPEID | STATS_BINOMIAL_TEST | STATS_CROSSTAB | STATS_F_TEST | STATS_KS_TEST | STATS_MODE | STATS_MW_TEST | STATS_ONE_WAY_ANOVA | STATS_T_TEST_ONE | STATS_T_TEST_PAIRED | STATS_T_TEST_INDEP | STATS_T_TEST_INDEPU | STATS_WSR_TEST | STDDEV | STDDEV_POP | STDDEV_SAMP | SUM | SYS_XMLAGG | SYS_OP_MAP_NONNULL
    | TAN | TANH | TRUNC | TRANSLATE | TRIM | TO_DSINTERVAL | TO_TIMESTAMP_TZ | TO_YMINTERVAL | TZ_OFFSET | TIMESTAMP_TO_SCN | TO_BINARY_DOUBLE | TO_BINARY_FLOAT | TO_BLOB | TO_CHAR | TO_CLOB | TO_DATE | TO_DSINTERVAL | TO_LOB | TO_MULTI_BYTE | TO_NCHAR | TO_NCLOB | TO_NUMBER | TO_SINGLE_BYTE | TO_TIMESTAMP | TO_TIMESTAMP_TZ | TO_YMINTERVAL | TREAT | TABLE
    | UPPER | UNISTR | UPDATEXML | UID | USER | USERENV | UNDER_PATH
    | VSIZE | VAR_POP | VAR_SAMP | VARIANCE | VALUE
    | WIDTH_BUCKET | WM_CONCAT
    | XMLAGG | XMLCAST | XMLCDATA | XMLCOLATTVAL | XMLCOMMENT | XMLCONCAT | XMLDIFF | XMLELEMENT | XMLEXISTS | XMLFOREST | XMLISVALID | XMLPARSE | XMLPATCH | XMLPI | XMLQUERY | XMLROOT | XMLSEQUENCE | XMLSERIALIZE | XMLTABLE | XMLTRANSFORM | XMLAGG | XMLTYPE
    // user defined
    | ((schema '.')? package_name '.')? ID ('@' dblink '.')? 
  | {$k.equals("any") || $k.equals("simple")}?
      ID
    // Special, i.e., although reserved, allowed for alias, column, or package name
    // TODO Re-assess: Actually at this point we want to accept 
    //                 `ID`, Pseudo columns, and all tokens defined
    //                 within the Lexer!
    | DIMENSION | DOCUMENT 
    | EMPTY
    | GROUP_ID 
    | INT 
    | MONTH
    | NAME 
    | RULES
    | SYS
    | ZONE
    // Pseudocolumns
    | CONNECT_BY_ISCYCLE | CONNECT_BY_ISLEAF
    | LEVEL
    | OBJECT_ID | OBJECT_VALUE | ORA_ROWSCN
    | ROWID | ROWNUM
    | '*'
  ;

// Lexer {{{1
// Keywords {{{2
// A {{{3
ABS                          : A B S;
ACOS                         : A C O S;
ADD_MONTHS                   : A D D '_' M O N T H S;
ALL                          : A L L;
AND                          : A N D;
ANY                          : A N Y;
ANYDATA                      : A N Y D A T A;
ANYTYPE                      : A N Y T Y P E;
ANYDATASET                   : A N Y D A T A S E T;
APPENDCHILDXML               : A P P E N D C H I L D X M L;
AS                           : A S;
ASET                         : A SPACES S E T {_text = "A SET";}; // XXX
ASC                          : A S C;
ASCII                        : A S C I I;
ASCIISTR                     : A S C I I S T R;
ASIN                         : A S I N;
AT                           : A T;
ATAN                         : A T A N;
ATAN2                        : A T A N '2';
AUTO                         : A U T O;
AUTOMATIC                    : A U T O M A T I C;
AVG                          : A V G;
// B {{{3
BREADTH                      : B R E A D T H;
BETWEEN                      : B E T W E E N;
BFILE                        : B F I L E;
BFILENAME                    : B F I L E N A M E;
BIN_TO_NUM                   : B I N '_' T O '_' N U M;
BINARY_DOUBLE                : B I N A R Y '_' D O U B L E;
BINARY_FLOAT                 : B I N A R Y '_' F L O A T;
BITAND                       : B I T A N D;
BLOCK                        : B L O C K;
BLOB                         : B L O B;
BOTH                         : B O T H;
BY                           : B Y;
BYTE                         : B Y T E;
// C {{{3
CANONICAL                    : C A N O N I C A L;
CARDINALITY                  : C A R D I N A L I T Y;
CAST                         : C A S T;
CHECK                        : C H E C K;
CHR                          : C H R;
CHAR                         : C H A R;
CHAR_CS                      : C H A R '_' C S;
CHARACTER                    : C H A R A C T E R;
CEIL                         : C E I L;
CLOB                         : C L O B;
CLUSTER_ID                   : C L U S T E R '_' I D;
COALESCE                     : C O A L E S C E;
CONNECT                      : C O N N E C T;
CONNECT_BY_ROOT              : C O N N E C T '_' B Y '_' R O O T;
COLLECT                      : C O L L E C T;
COLUMN_VALUE                 : C O L U M N '_' V A L U E; 
CONSTRAINT                   : C O N S T R A I N T;
COMPATIBILITY                : C O M P A T I B I L I T Y;
COMPOSE                      : C O M P O S E;
CONCAT                       : C O N C A T;
CONNECT_BY_ISCYCLE           : C O N N E C T '_' B Y '_' I S C Y C L E;
CONNECT_BY_ISLEAF            : C O N N E C T '_' B Y '_' I S L E A F;
CONTENT                      : C O N T E N T;
CONVERT                      : C O N V E R T;
COS                          : C O S;
COSH                         : C O S H;
COST                         : C O S T;
CROSS                        : C R O S S;
CUME_DIST                    : C U M E '_' D I S T;
CURRENT                      : C U R R E N T;
CURRENT_DATE                 : C U R R E N T '_' D A T E;
CURRENT_TIMESTAMP            : C U R R E N T '_' T I M E S T A M P;
CHARTOROWID                  : C H A R T O R O W I D; 
CLUSTER_PROBABILITY          : C L U S T E R '_' P R O B A B I L I T Y;
CLUSTER_SET                  : C L U S T E R '_' S E T;
CORR_K                       : C O R R '_' K;
CORR_S                       : C O R R '_' S;
COUNT                        : C O U N T;
COVAR_POP                    : C O V A R '_' P O P;
COVAR_SAMP                   : C O V A R '_' S A M P;
CUBE                         : C U B E;
CURRVAL                      : C U R R V A L;
CASE                         : C A S E;
CURSOR                       : C U R S O R;
CYCLE                        : C Y C L E;
// D {{{3
DATE                         : D A T E;
DAY                          : D A Y;
DBTIMEZONE                   : D B T I M E Z O N E;
DEC                          : D E C;
DECREMENT                    : D E C R E M E N T;
DECIMAL                      : D E C I M A L;
DECODE                       : D E C O D E;
DECOMPOSE                    : D E C O M P O S E;
DESC                         : D E S C;
DIMENSION                    : D I M E N S I O N;
DISTINCT                     : D I S T I N C T;
DOUBLE                       : D O U B L E;
DELETEXML                    : D E L E T E X M L; 
DEPTH                        : D E P T H;
DUMP                         : D U M P;
DENSE_RANK                   : D E N S E '_' R A N K;
DOCUMENT                     : D O C U M E N T;
DEFAULT                      : D E F A U L T;
// E {{{3
ELSE                         : E L S E;
EMPTY                        : E M P T Y;
EMPTY_BLOB                   : E M P T Y '_' B L O B;
EMPTY_CLOB                   : E M P T Y '_' C L O B;
END                          : E N D;
EQUALS_PATH                  : E Q U A L S '_' P A T H;
ESCAPE                       : E S C A P E;
EXP                          : E X P;
EXTRACT                      : E X T R A C T;
EXTRACTVALUE                 : E X T R A C T V A L U E;
EXISTSNODE                   : E X I S T S N O D E;
EXISTS                       : E X I S T S;
EXCLUDE                      : E X C L U D E;
EVALNAME                     : E V A L N A M E;
// F {{{3
FIRST                        : F I R S T;
FIRST_VALUE                  : F I R S T '_' V A L U E;
FLOAT                        : F L O A T;
FLOOR                        : F L O O R;
FOLLOWING                    : F O L L O W I N G;
FOR                          : F O R;
FROM                         : F R O M;
FROM_TZ                      : F R O M '_' T Z;
FEATURE_ID                   : F E A T U R E '_' I D;
FEATURE_SET                  : F E A T U R E '_' S E T;
FEATURE_VALUE                : F E A T U R E '_' V A L U E;
FULL                         : F U L L;
// G {{{3
GREATEST                     : G R E A T E S T;
GROUP_ID                     : G R O U P '_' I D;
GROUP                        : G R O U P;
GROUPING                     : G R O U P I N G;
GROUPING_ID                  : G R O U P I N G '_' I D;
// H {{{3
HAVING                       : H A V I N G;
HOUR                         : H O U R;
HEXTORAW                     : H E X T O R A W;
// I {{{3
IGNORE                       : I G N O R E;
IN                           : I N;
INNER                        : I N N E R;
INTERSECT                    : I N T E R S E C T;
INCLUDE                      : I N C L U D E;
INCREMENT                    : I N C R E M E N T;
IS                           : I S;
ITERATE                      : I T E R A T E;
INFINITE                     : I N F I N I T E;
INITCAP                      : I N I T C A P;
INSTR                        : I N S T R;
INSTRB                       : I N S T R B;
INSTRC                       : I N S T R C;
INSTR2                       : I N S T R '2';
INSTR4                       : I N S T R '4';
INT                          : I N T;
INTEGER                      : I N T E G E R;
INTERVAL                     : I N T E R V A L;
INSERTCHILDXML               : I N S E R T C H I L D X M L;
INSERTCHILDXMLAFTER          : I N S E R T C H I L D X M L A F T E R;
INSERTCHILDXMLBEFORE         : I N S E R T C H I L D X M L B E F O R;
INSERTXMLAFTER               : I N S E R T X M L A F T E R;
INSERTXMLBEFORE              : I N S E R T X M L B E F O R E;
// J {{{3
JOIN                         : J O I N;
// K {{{3
KEEP                         : K E E P;
// L {{{3
LAG                          : L A G;
LAST                         : L A S T;
LAST_DAY                     : L A S T '_' D A Y;
LEAD                         : L E A D;
LEADING                      : L E A D I N G;
LEAST                        : L E A S T;
LENGTH                       : L E N G T H;
LENGTHB                      : L E N G T H B;
LENGTHC                      : L E N G T H C;
LENGTH2                      : L E N G T H '2';
LENGTH4                      : L E N G T H '4';
LEVEL                        : L E V E L;
LEFT                         : L E F T;
LN                           : L N;
LOCAL                        : L O C A L;
LOCALTIMESTAMP               : L O C A L T I M E S T A M P;
LOG                          : L O G;
LONG                         : L O N G;
LOWER                        : L O W E R;
LPAD                         : L P A D;
LTRIM                        : L T R I M;
LNNVL                        : L N N V L;
LISTAGG                      : L I S T A G G;
LIKE                         : L I K E;
LIKEC                        : L I K E C;
LIKE2                        : L I K E '2';
LIKE4                        : L I K E '4';
LOCKED                       : L O C K E D;
// M {{{3
MAIN                         : M A I N;
MAXVALUE                     : M A X V A L U E;
MEASURES                     : M E A S U R E S;
MINUS                        : M I N U S;
MINUTE                       : M I N U T E;
MINVALUE                     : M I N V A L U E;
MOD                          : M O D;
MODEL                        : M O D E L;
MONTH                        : M O N T H;
MONTHS_BETWEEN               : M O N T H S '_' B E T W E E N;
MULTISET                     : M U L T I S E T;
MAX                          : M A X;
MEDIAN                       : M E D I A N;
MIN                          : M I N;
MEMBER                       : M E M B E R;
// N {{{3
NAME                         : N A M E;
NAN                          : N A N;
NATIONAL                     : N A T I O N A L;
NATURAL                      : N A T U R A L;
NANVL                        : N A N V L;
NAV                          : N A V;
NCHR                         : N C H R;
NCHAR                        : N C H A R;
NCHAR_CS                     : N C H A R '_' C S;
NCLOB                        : N C L O B;
NEW                          : N E W;
NEW_TIME                     : N E W '_' T I M E;
NEXT_DAY                     : N E X T '_' D A Y;
NLS_INITCAP                  : N L S '_' I N I T C A P;
NLS_CHARSET_ID               : N L S '_' C H A R S E T '_' I D;
NLS_CHARSET_DECL_LEN         : N L S '_' C H A R S E T '_' D E C L '_' L E N;
NLS_CHARSET_NAME             : N L S '_' C H A R S E T '_' N A M E;
NLS_LOWER                    : N L S '_' L O W E R;
NLS_UPPER                    : N L S '_' U P P E R;
NLSSORT                      : N L S S O R T;
NO                           : N O;
NOCYCLE                      : N O C Y C L E;
NOWAIT                       : N O W A I T;
NTH_VALUE                    : N T H '_' V A L U E;
NULL                         : N U L L;
NULLS                        : N U L L S;
NUMBER                       : N U M B E R;
NUMERIC                      : N U M E R I C;
NVARCHAR2                    : N V A R C H A R '2';
NVL                          : N V L;
NUMTODSINTERVAL              : N U M T O D S I N T E R V A L; 
NUMTOYMINTERVAL              : N U M T O Y M I N T E R V A L;
NULLIF                       : N U L L I F;
NVL2                         : N V L '2';
NEXTVAL                      : N E X T V A L;
NOT                          : N O T;
// O {{{3
ON                           : O N;
OR                           : O R;
OF                           : O F;
ONLY                         : O N L Y;
OPTION                       : O P T I O N;
ORDAUDIO                     : O R D A U D I O;
ORDER                        : O R D E R;
ORDIMAGE                     : O R D I M A G E;
ORDVIDEO                     : O R D V I D E O;
ORDDOC                       : O R D D O C;
ORDDICOM                     : O R D D I C O M;
OVER                         : O V E R;
OUTER                        : O U T E R;
ORA_DST_AFFECTED             : O R A '_' D S T '_' A F F E C T E D;
ORA_DST_CONVERT              : O R A '_' D S T '_' C O N V E R T;
ORA_DST_ERROR                : O R A '_' D S T '_' E R R O R;
ORA_HASH                     : O R A '_' H A S H;
ORA_ROWSCN                   : O R A '_' R O W S C N;
OBJECT_ID                    : O B J E C T '_' I D;
OBJECT_VALUE                 : O B J E C T '_' V A L U E;
// P {{{3
PARTITION                    : P A R T I T I O N;
PASSING                      : P A S S I N G;
PIVOT                        : P I V O T;
POWERMULTISET                : P O W E R M U L T I S E T;
POWERMULTISET_BY_CARDINALITY : P O W E R M U L T I S E T '_' B Y '_' C A R D I N A L I T Y;
POWER                        : P O W E R;
PREDICTION                   : P R E D I C T I O N;
PREDICTION_BOUNDS            : P R E D I C T I O N '_' B O U N D S; 
PREDICTION_COST              : P R E D I C T I O N '_' C O S T;
PREDICTION_DETAILS           : P R E D I C T I O N '_' D E T A I L S;
PREDICTION_PROBABILITY       : P R E D I C T I O N '_' P R O B A B I L I T Y;
PREDICTION_SET               : P R E D I C T I O N '_' S E T;
PATH                         : P A T H;
PERCENT_RANK                 : P E R C E N T '_' R A N K;
PERCENTILE_CONT              : P E R C E N T I L E '_' C O N T;
PERCENTILE_DISC              : P E R C E N T I L E '_' D I S C;
PRIOR                        : P R I O R;
PRESENT                      : P R E S E N T;
PRECISION                    : P R E C I S I O N;
PRECEDING                    : P R E C E D I N G;
// R {{{3
RANGE                        : R A N G E;
RATIO_TO_REPORT              : R A T I O '_' T O '_' R E P O R T;
RAW                          : R A W;
READ                         : R E A D;
REAL                         : R E A L;
REMAINDER                    : R E M A I N D E R;
REPLACE                      : R E P L A C E;
REFERENCE                    : R E F E R E N C E;
REGEXP_COUNT                 : R E G E X P '_' C O U N T;
REGEXP_INSTR                 : R E G E X P '_' I N S T R;
REGEXP_REPLACE               : R E G E X P '_' R E P L A C E;
REGEXP_SUBSTR                : R E G E X P '_' S U B S T R;
REGEXP_LIKE                  : R E G E X P '_' L I K E;
RESPECT                      : R E S P E C T;
RETURN                       : R E T U R N;
RETURNING                    : R E T U R N I N G;
REVERSE                      : R E V E R S E;
RIGHT                        : R I G H T;
ROUND                        : R O U N D;
ROW                          : R O W;
ROLLUP                       : R O L L U P;
ROWNUM                       : R O W N U M;
ROW_NUMBER                   : R O W '_' N U M B E R;
ROWS                         : R O W S;
ROWID                        : R O W I D;
RPAD                         : R P A D;
RTRIM                        : R T R I M;
RANK                         : R A N K;
RAWTOHEX                     : R A W T O H E X;
RAWTONHEX                    : R A W T O N H E X;
ROWIDTOCHAR                  : R O W I D T O C H A R;
ROWIDTONCHAR                 : R O W I D T O N C H A R;
REGR_SLOPE                   : R E G R '_' S L O P E;
REGR_INTERCEPT               : R E G R '_' I N T E R C E P T;
REGR_COUNT                   : R E G R '_' C O U N T;
REGR_R2                      : R E G R '_' R '2';
REGR_AVGX                    : R E G R '_' A V G X;
REGR_AVGY                    : R E G R '_' A V G Y;
REGR_SXX                     : R E G R '_' S X X;
REGR_SYY                     : R E G R '_' S Y Y;
REGR_SXY                     : R E G R '_' S X Y;
RULES                        : R U L E S;
// S {{{3
SAMPLE                       : S A M P L E;
SCN                          : S C N;
SEARCH                       : S E A R C H;
SECOND                       : S E C O N D;
SEED                         : S E E D;
SELECT                       : S E L E C T;
SET                          : S E T;
SETS                         : S E T S;
SEQUENTIAL                   : S E Q U E N T I A L;
SDO_GEOMETRY                 : S D O '_' G E O M E T R Y;
SDO_TOPO_GEOMETRY            : S D O '_' T O P O '_' G E O M E T R Y;
SDO_GEORASTER                : S D O '_' G E O R A S T E R;
SI_STILLIMAGE                : S I '_' S T I L L I M A G E;
SI_AVERAGECOLOR              : S I '_' A V E R A G E C O L O R;
SI_POSITIONALCOLOR           : S I '_' P O S I T I O N A L C O L O R;
SI_COLORHISTOGRAM            : S I '_' C O L O R H I S T O G R A M;
SI_TEXTURE                   : S I '_' T E X T U R E;
SI_FEATURELIST               : S I '_' F E A T U R E L I S T;
SI_COLOR                     : S I '_' C O L O R;
SIBLINGS                     : S I B L I N G S;
SIGN                         : S I G N;
SINGLE                       : S I N G L E;
SIN                          : S I N;
SINH                         : S I N H;
SKIP_                        : S K I P;
SMALLINT                     : S M A L L I N T;
SNAPSHOT                     : S N A P S H O T;
SOUNDEX                      : S O U N D E X;
SQRT                         : S Q R T;
STANDALONE                   : S T A N D A L O N E;
START                        : S T A R T;
STDDEV                       : S T D D E V;
STDDEV_POP                   : S T D D E V '_' P O P;
STDDEV_SAMP                  : S T D D E V '_' S A M P;
SUBPARTITION                 : S U B P A R T I T I O N;
SUBSTR                       : S U B S T R;
SUBSTRB                      : S U B S T R B;
SUBSTRC                      : S U B S T R C;
SUBSTR2                      : S U B S T R '2';
SUBSTR4                      : S U B S T R '4';
SUM                          : S U M;
SYS                          : S Y S;
SYS_CONNECT_BY_PATH          : S Y S '_' C O N N E C T '_' B Y '_' P A T H;
SYS_CONTEXT                  : S Y S '_' C O N T E X T;
SYS_OP_MAP_NONNULL           : S Y S '_' O P '_' M A P '_' N O N N U L L;
SYSDATE                      : S Y S D A T E;
SYSTIMESTAMP                 : S Y S T I M S T A M P;
SESSIONTIMEZONE              : S E S S I O N T I M E Z O N E;
SYS_EXTRACT_UTC              : S Y S '_' E X T R A C T '_' U T C;
SCN_TO_TIMESTAMP             : S C N '_' T O '_' T I M E S T A M P;
SYS_DBURIGEN                 : S Y S '_' D B U R I G E N;
SYS_XMLAGG                   : S Y S '_' X M L A G G;
SYS_XMLGEN                   : S Y S '_' X M L G E N;
SYS_GUID                     : S Y S '_' G U I D;
SYS_TYPEID                   : S Y S '_' T Y P E I D;
STATS_BINOMIAL_TEST          : S T A T S '_' B I N O M I A L '_' T E S T;
STATS_CROSSTAB               : S T A T S '_' C R O S S T A B;
STATS_F_TEST                 : S T A T S '_' F '_' T E S T;
STATS_KS_TEST                : S T A T S '_' K S '_' T E S T;
STATS_MODE                   : S T A T S '_' M O D E;
STATS_MW_TEST                : S T A T S '_' M W '_' T E S T;
STATS_ONE_WAY_ANOVA          : S T A T S '_' O N E '_' W A Y '_' A N O V A;
STATS_T_TEST_ONE             : S T A T S '_' T '_' O N E;
STATS_T_TEST_PAIRED          : S T A T S '_' T '_' T E S T '_' P A I R E D;
STATS_T_TEST_INDEP           : S T A T S '_' T '_' T E S T '_' I N D E P;
STATS_T_TEST_INDEPU          : S T A T S '_' T '_' T E S T '_' I N D E P U;
STATS_WSR_TEST               : S T A T S '_' W S T '_' T E S T;
SOME                         : S O M E;
SUBMULTISET                  : S U B M U L T I S E T;
// T {{{3
TABLE                        : T A B L E;
TAN                          : T A N;
TANH                         : T A N H;
THE                          : T H E;
//TIMEZONE                     : T I M E SPACES Z O N E {_text = "TIME ZONE";}; // XXX
TIME                         : T I M E;
TIMESTAMP                    : T I M E S T A M P;
TIMESTAMP_TO_SCN             : T I M E S T A M P '_' T O '_' S C N;
TIMEZONE_HOUR                : T I M E Z O N E '_' H O U R;
TIMEZONE_MINUTE              : T I M E Z O N E '_' M I N U T E;
TIMEZONE_REGION              : T I M E Z O N E '_' R E G I O N;
TIMEZONE_ABBR                : T I M E Z O N E '_' A B B R;
TO                           : T O;
TO_BINARY_DOUBLE             : T O '_' B I N A R Y '_' D O U B L E;
TO_BINARY_FLOAT              : T O '_' B I N A R Y '_' F L O A T;
TO_BLOB                      : T O '_' B L O B; 
TO_CHAR                      : T O '_' C H A R;
TO_CLOB                      : T O '_' C L O B;
TO_DATE                      : T O '_' D A T E;
TO_DSINTERVAL                : T O '_' D S I N T E R V A L;
TO_LOB                       : T O '_' L O B; 
TO_MULTI_BYTE                : T O '_' M U L T I '_' B Y T E; 
TO_NCHAR                     : T O '_' N C H A R;
TO_NCLOB                     : T O '_' N C L O B;
TO_NUMBER                    : T O '_' N U M B E R;
TO_SINGLE_BYTE               : T O '_' S I N G L E '_' B Y T E;
TO_TIMESTAMP                 : T O '_' T I M E S T A M P;
TO_TIMESTAMP_TZ              : T O '_' T I M E S T A M P '_' T Z;
TO_YMINTERVAL                : T O '_' Y M I N T E R V A L;
TRAILING                     : T R A I L I N G;
TRANSLATE                    : T R A N S L A T E;
TREAT                        : T R E A T;
TRIM                         : T R I M;
TRUNC                        : T R U N C;
TZ_OFFSET                    : T Z '_' O F F S E T;
THEN                         : T H E N;
// U {{{3
UID                          : U I D;
UNBOUNDED                    : U N B O U N D E D;
UNIQUE                       : U N I Q U E;
UNISTR                       : U N I S T R;
UNPIVOT                      : U N P I V O T;
UNTIL                        : U N T I L;
UPDATE                       : U P D A T E;
UPDATED                      : U P D A T E D;
UPDATEXML                    : U P D A T E X M L;
UPPER                        : U P P E R;
UPSERT                       : U P S E R T;
URITYPE                      : U R I T Y P E;
UROWID                       : U R O W I D;
USING                        : U S I N G;
USER                         : U S E R;
USERENV                      : U S E R E N V;
UNDER_PATH                   : U N D E R '_' P A T H;
UNION                        : U N I O N;
// V {{{3
VARCHAR                      : V A R C H A R;
VARCHAR2                     : V A R C H A R '2';
VAR_POP                      : V A R '_' P O P;
VAR_SAMP                     : V A R '_' S A M P;
VARIANCE                     : V A R I A N C E;
VARYING                      : V A R Y I N G;
VERSION                      : V E R S I O N;
VERSIONS                     : V E R S I O N S;
VSIZE                        : V S I Z E;
VALUE                        : V A L U E;
VALUES                       : V A L U E S;
// W {{{3
WAIT                         : W A I T;
WELLFORMED                   : W E L L F O R M E D;
WHEN                         : W H E N;
WHERE                        : W H E R E;
WIDTH_BUCKET                 : W I D T H '_' B U C K E T;
WITH                         : W I T H;
WITHIN                       : W I T H I N;
WM_CONCAT                    : W M '_' C O N C A T;
// X {{{3
XML                          : X M L;
XMLAGG                       : X M L A G G;
XMLCAST                      : X M L C A S T;
XMLCDATA                     : X M L C D A T A;
XMLCOLATTVAL                 : X M L C O L A T T V A L;
XMLCOMMENT                   : X M L C O M M E N T;
XMLCONCAT                    : X M L C O N C A T; 
XMLDIFF                      : X M L D I F F;
XMLELEMENT                   : X M L E L E M E N T;
XMLEXISTS                    : X M L E X I S T S;
XMLFOREST                    : X M L F O R E S T;
XMLISVALID                   : X M L I S V A L I D; 
XMLPATCH                     : X M L P A T C H; 
XMLPARSE                     : X M L P A R S E;
XMLPI                        : X M L P I;
XMLQUERY                     : X M L Q U E R Y;
XMLROOT                      : X M L R O O T;
XMLSEQUENCE                  : X M L S E Q U E N C E;
XMLSERIALIZE                 : X M L S E R I A L I Z E;
XMLTABLE                     : X M L T A B L E;
XMLTRANSFORM                 : X M L T R A N S F O R M;
XMLTYPE                      : X M L T Y P E;
// Y {{{3
YEAR                         : Y E A R;
YES                          : Y E S;
// Z {{{3
ZONE                         : Z O N E;

// Rules {{{2
SPACES
  : [ \t\r\n]+ -> skip
  ;

SINGLE_LINE_COMMENT
  : '--' ( ~('\r' | '\n') )* (NEWLINE|EOF) -> channel(HIDDEN)
  ;

MULTI_LINE_COMMENT
  : '/*' .*? '*/' -> channel(HIDDEN)
  ;

SIMPLE_STRING_LITERAL
  : '\'' (~('\'' | '\r' | '\n') | '\'' '\'' | NEWLINE)* '\''
  ;

QUOTED_STRING_LITERAL
  : [Qq] '\'' ('[' .*? ']') '\''
  | [Qq] '\'' ('{' .*? '}') '\''
  | [Qq] '\'' ('(' .*? ')') '\''
  | [Qq] '\'' ('!' .*? '!') '\''
  | [Qq] '\'' ('#' .*? '#') '\''
  | [Qq] '\'' ('<' .*? '>') '\''
  | [Qq] '\'' ('"' .*? '"') '\''
  ;

NATIONAL_STRING_LITERAL
  : [Nn]? (SIMPLE_STRING_LITERAL | QUOTED_STRING_LITERAL)
  ;

INTEGER_LITERAL
  : '0' | [1-9] [0-9]* 
  ;

FLOAT_LITERAL
  //: INTEGER_LITERAL? '.' INTEGER_LITERAL ([dD] | [fF])?
  : INTEGER_LITERAL? '.' [0-9]+ ([dD] | [fF])?
  ;

SCIENTIFIC_LITERAL
  : (INTEGER_LITERAL? '.' [0-9]+ | INTEGER_LITERAL)
    ([eE] ('+'|'-')? (INTEGER_LITERAL? '.' [0-9]+ | INTEGER_LITERAL))?
    ([dD] | [fF])?
  ;

// Quoted and nonquoted identifier
ID
  : LETTER (LETTER|DIGIT)* 
  | '"' .+? '"'
  ;

fragment NEWLINE                   : '\r'? '\n';
fragment LETTER                    : [a-zA-Z\u0080-\u00FF_$#] ;
fragment DIGIT                     : [0-9] ; 
fragment A                         : [aA] ;
fragment B                         : [bB] ;
fragment C                         : [cC] ;
fragment D                         : [dD] ;
fragment E                         : [eE] ;
fragment F                         : [fF] ;
fragment G                         : [gG] ;
fragment H                         : [hH] ;
fragment I                         : [iI] ;
fragment J                         : [jJ] ;
fragment K                         : [kK] ;
fragment L                         : [lL] ;
fragment M                         : [mM] ;
fragment N                         : [nN] ;
fragment O                         : [oO] ;
fragment P                         : [pP] ;
fragment Q                         : [qQ] ;
fragment R                         : [rR] ;
fragment S                         : [sS] ;
fragment T                         : [tT] ;
fragment U                         : [uU] ;
fragment V                         : [vV] ;
fragment W                         : [wW] ;
fragment X                         : [xX] ;
fragment Y                         : [yY] ;
fragment Z                         : [zZ] ;
