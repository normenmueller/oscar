/*******************************************************************************\
 * Name:              Oracle(c) PL/SQL 11g R2 Grammar                          *
 * version:           0.1.0.0                                                  *
 * synopsis:          n/a                                                      *
 * description:       Please see README.md                                     *
 * homepage:          https://github.com/normenmueller/parser-plsql            *
 * license:           Please see LICENSE                                       *
 * author:            Normen Müller                                            *
 * maintainer:        normen.mueller@gmail.com                                 *
 * copyright:         2016, Normen Müller                                      *
 * category:          Database                                                 *
 * comment:           v0.1.0.0 Select statement                                *
\*******************************************************************************/
grammar Plsql;

// Parser {{{1

statement
  : select_statement
  ;

// DML {{{2

// Select {{{3
select_statement
  : subquery for_update?
  ;

subquery
  : (query_block | '(' subquery ')')
    subquery_op* order_by?
  ;

subquery_op
  : (UNION ALL? | INTERSECT | MINUS)
    (query_block | '(' subquery ')')
  ;

query_block
  : factoring_clause?
    SELECT (DISTINCT | UNIQUE | ALL)? select_list
    from_clause
    where_clause?
    hierarchical_query?
    group_by?
    model_clause?
  ;

factoring_clause
  : WITH factoring_elem
      (',' factoring_elem)*
  ;

factoring_elem
  : query_name ('(' column_name (',' column_name)* ')')? AS '(' subquery ')'
    search_clause?
    cycle_clause?
  ;

search_clause
  : SEARCH (DEPTH | BREADTH)
    FIRST BY search_elems
    SET column_name
  ;

search_elems
  : search_elem
      (',' search_elem)*
  ;

search_elem
  : column_name (ASC | DESC)? (NULLS FIRST | NULLS LAST)?
  ;

cycle_clause
  : CYCLE column_name (',' column_name)*
    SET column_name TO expression
    DEFAULT expression
  ;

select_list
  : '*'
  | select_list_elems
  ;

select_list_elems
  : select_list_elem
      (',' select_list_elem)*
  ;

select_list_elem
  : ( tableview_name '.' '*'
    | expression
    )
    column_alias?
  ;

from_clause
  : FROM table_refs
  ;

table_refs
  : table_ref
      (',' table_ref)*
  ;

table_ref
  : table_ref_aux
    join_clause*
    (pivot_clause | unpivot_clause)?
  ;

table_ref_aux
  : ( table_clause (pivot_clause | unpivot_clause)?
    | '(' table_ref subquery_op* ')' (pivot_clause | unpivot_clause)?
    | ONLY '(' table_clause ')'
    | table_clause (pivot_clause | unpivot_clause)?
    )
    flashback_query*
    table_alias?
  ;

table_clause
  : table_collection
  | '(' select_statement restriction_clause? ')'
  | tableview_name sample_clause?
  ;

table_collection
  : (TABLE | THE)
    ('(' subquery ')' | '(' expression ')' ('(' '+' ')')?)
  ;
  
restriction_clause
  : WITH (READ ONLY | CHECK OPTION (CONSTRAINT constraint_name)?)
  ;

sample_clause
  : SAMPLE BLOCK?
    '(' expression (',' expression)? ')'
    seed_part?
  ;

seed_part
  : SEED '(' expression ')'
  ;

join_clause
  : query_partition?
    (CROSS | NATURAL)? (INNER | outer_join_type)? JOIN table_ref_aux query_partition?
    (join_on_part | join_using_part)*
  ;

join_on_part
  : ON condition
  ;

join_using_part
  : USING '(' column_name (',' column_name)* ')'
  ;

outer_join_type
  : (FULL | LEFT | RIGHT) OUTER?
  ;

query_partition
  : PARTITION BY
    ( '(' subquery ')'
    | expression_list
    | expression (',' expression)*
    )
  ;
flashback_query
  : VERSIONS BETWEEN (SCN | TIMESTAMP) expression
  | AS OF (SCN | TIMESTAMP | SNAPSHOT) expression
  ;

pivot_clause
  : PIVOT XML?
    '(' pivot_element (',' pivot_element)* 
        pivot_for_clause
        pivot_in_clause
    ')'
  ;

pivot_element
  : aggregate_function_name '(' expression ')' column_alias?
  ;

pivot_for_clause
  : FOR ( column_name
        | '(' column_name (',' column_name)* ')'
        )
  ;

pivot_in_clause
  : IN '(' ( subquery
           | ANY (',' ANY)*
           | pivot_in_elem (',' pivot_in_elem)*
           )
       ')'
  ;

pivot_in_elem
  : (expression | expression_list) column_alias?
  ;

unpivot_clause
  : UNPIVOT ((INCLUDE | EXCLUDE) NULLS)?
    '(' ( column_name
        | '(' column_name (',' column_name)* ')'
        )
        pivot_for_clause
        unpivot_in_clause
    ')'
  ;

unpivot_in_clause
  : IN '(' unpivot_in_elem (',' unpivot_in_elem)* ')'
  ;

unpivot_in_elem
  : ( column_name 
    | '(' column_name (',' column_name)* ')'
    )
    (AS (constant | '(' constant (',' constant)* ')'))?
  ;

where_clause
  : WHERE (current_of_clause | condition_wrapper)
  ;

current_of_clause
  : CURRENT OF cursor_name
  ;

hierarchical_query
  : CONNECT BY NOCYCLE? condition start_part?
  | start_part CONNECT BY NOCYCLE? condition
  ;

start_part
  : START WITH condition
  ;

group_by
  : GROUP BY group_by_elem (',' group_by_elem)* having_clause?
  | having_clause (GROUP BY group_by_elem (',' group_by_elem)*)?
  ;

group_by_elem
  : grouping_sets
  | rollup_cube
  | expression
  ;

rollup_cube
  : (ROLLUP|CUBE)
    '(' grouping_sets_elem (',' grouping_sets_elem)* ')'
  ;

grouping_sets
  : GROUPING SETS
    '(' grouping_sets_elem (',' grouping_sets_elem)* ')'
  ;

grouping_sets_elem
  : rollup_cube
  | expression_list
  | expression
  ;

having_clause
  : HAVING condition
  ;

model_clause
  : MODEL cell_reference_op* return_rows_clause? reference_model* main_model
  ;

cell_reference_op
  : (IGNORE | KEEP) NAV
  | UNIQUE (DIMENSION | SINGLE REFERENCE)
  ;

return_rows_clause
  : RETURN (UPDATED | ALL) ROWS
  ;
reference_model
  : REFERENCE reference_model_name
    ON '(' subquery ')' model_column_clause cell_reference_op*
  ;

main_model
  : (MAIN main_model_name)? model_column_clause cell_reference_op* model_rules
  ;

model_column_clause
  : partition_by?
    DIMENSION BY model_columns
    MEASURES model_columns
  ;

partition_by
  : PARTITION BY model_columns
  ;

model_columns
  : '(' model_column (',' model_column)*  ')'
  ;

model_column
  : expression table_alias?
  ;

model_rules
  : rules_part? '(' model_rules_elem (',' model_rules_elem)* ')'
  ;

rules_part
  : RULES (UPDATE | UPSERT ALL?)? ((AUTOMATIC | SEQUENTIAL) ORDER)? model_iterate?
  ;

model_rules_elem
  : (UPDATE | UPSERT ALL?)? cell_assignment order_by? '=' expression
  ;

cell_assignment
  : model_expression
  ;

model_iterate
  : ITERATE '(' expression ')' until_part?
  ;

until_part
  : UNTIL '(' condition ')'
  ;

order_by
  : ORDER SIBLINGS? BY order_by_elem (',' order_by_elem)*
  ;

order_by_elem
  : expression (ASC | DESC)? (NULLS (FIRST | LAST))?
  ;

for_update
  : FOR UPDATE of_part? for_update_op?
  ;

of_part
  : OF column_name (',' column_name)*
  ;

for_update_op
  : SKIP_ LOCKED 
  | NOWAIT 
  | WAIT expression
  ;

// Conditions {{{2
condition : expression ;
condition_wrapper : expression ;

// Expressions {{{2
expression               : cursor_expression | logical_and_expression ( OR logical_and_expression )* ;
expression_list          : '(' expression? (',' expression)* ')' ;
expression_wrapper       : expression ;
cursor_expression        : CURSOR '(' subquery ')' ;
logical_and_expression   : negated_expression ( AND negated_expression )* ;
negated_expression       : NOT negated_expression | equality_expression ;
equality_expression      : multiset_expression (IS NOT? (NULL | NAN | PRESENT | INFINITE | A_LETTER SET | EMPTY | OF TYPE? '(' ONLY? type_spec (',' type_spec)* ')'))* ;
multiset_expression      : relational_expression (multiset_type OF? concatenation)? ;
multiset_type            : MEMBER | SUBMULTISET ;
relational_expression    : compound_expression (( '=' | not_equal_op | '<' | '>' | less_than_or_equals_op | greater_than_or_equals_op ) compound_expression)* ;
compound_expression      : concatenation (NOT? (IN in_elements | BETWEEN between_elements | like_type concatenation like_escape_part?))? ;
like_type                : LIKE | LIKEC | LIKE2 | LIKE4 ;
like_escape_part         : ESCAPE concatenation ;
in_elements              : '(' subquery ')' | '(' concatenation_wrapper (',' concatenation_wrapper)* ')' | constant | bind_variable | general_element ;
between_elements         : concatenation AND concatenation ;
concatenation            : additive_expression (concatenation_op additive_expression)* ;
concatenation_wrapper    : concatenation ;
additive_expression      : multiply_expression (('+' | '-') multiply_expression)* ;
multiply_expression      : datetime_expression (('*' | '/') datetime_expression)* ;
datetime_expression      : model_expression (AT (LOCAL | TIME ZONE concatenation_wrapper) | interval_expression)?  ;
interval_expression      : DAY ('(' concatenation_wrapper ')')? TO SECOND ('(' concatenation_wrapper ')')?
                         | YEAR ('(' concatenation_wrapper ')')? TO MONTH
                         ;
model_expression         : unary_expression ('[' model_expression_element ']')? ;
model_expression_element : (ANY | condition_wrapper) (',' (ANY | condition_wrapper))*
                         | single_column_for_loop (',' single_column_for_loop)*
                         | multi_column_for_loop
                         ;
single_column_for_loop   : FOR column_name (IN expression_list | for_like_part? FROM ex1=expression TO ex2=expression for_increment_decrement_type ex3=expression) ;
for_like_part            : LIKE expression ;
for_increment_decrement_type : INCREMENT | DECREMENT ;
multi_column_for_loop    : FOR '(' column_name (',' column_name)* ')' IN '(' (subquery | '(' expression_list (',' expression_list)* ')') ')' ;
unary_expression         : '-' unary_expression
                         | '+' unary_expression
                         | PRIOR unary_expression
                         | CONNECT_BY_ROOT unary_expression
                         | NEW unary_expression
                         | DISTINCT unary_expression
                         | ALL unary_expression
                         | case_statement
                         | quantified_expression
                         | standard_function
                         | atom
                         ;
case_statement           : CASE expression? (WHEN expression THEN expression)+ (ELSE expression)? END ;
atom                     : table_element outer_join_sign
                         | bind_variable
                         | constant
                         | general_element
                         | '(' (subquery ')' subquery_op* | expression_or_vector ')')
                         ;
expression_or_vector     : expression (vector_expr)? ;
vector_expr              : ',' expression (',' expression)* ;
quantified_expression    : (SOME | EXISTS | ALL | ANY) ('(' subquery ')' | '(' expression_wrapper ')') ;
standard_function        : over_clause_keyword function_argument_analytic over_clause?
                         | /*TODO stantard_function_enabling_using*/ regular_id function_argument_modeling using_clause?
                         | COUNT '(' ( '*' | (DISTINCT | UNIQUE | ALL)? concatenation_wrapper) ')' over_clause?
                         | (CAST | XMLCAST) '(' (MULTISET '(' subquery ')' | concatenation_wrapper) AS type_spec ')'
                         | CHR '(' concatenation_wrapper USING NCHAR_CS ')'
                         | COLLECT '(' (DISTINCT | UNIQUE)? concatenation_wrapper collect_order_by_part? ')'
                         | within_or_over_clause_keyword function_argument within_or_over_part+
                         | DECOMPOSE '(' concatenation_wrapper (CANONICAL | COMPATIBILITY)? ')'
                         | EXTRACT '(' regular_id FROM concatenation_wrapper ')'
                         | (FIRST_VALUE | LAST_VALUE) function_argument_analytic respect_or_ignore_nulls? over_clause
                         | standard_prediction_function_keyword '(' expression_wrapper (',' expression_wrapper)* cost_matrix_clause? using_clause? ')'
                         | TRANSLATE '(' expression_wrapper (USING (CHAR_CS | NCHAR_CS))? (',' expression_wrapper)* ')'
                         | TREAT '(' expression_wrapper AS REF? type_spec ')'
                         | TRIM '(' ((LEADING | TRAILING | BOTH)? quoted_string? FROM)? concatenation_wrapper ')'
                         | XMLAGG '(' expression_wrapper order_by? ')' ('.' general_element_part)?
                         | (XMLCOLATTVAL|XMLFOREST) '(' xml_multiuse_expression_element (',' xml_multiuse_expression_element)* ')' ('.' general_element_part)?
                         | XMLELEMENT '(' (ENTITYESCAPING | NOENTITYESCAPING)? (NAME | EVALNAME)? expression_wrapper
                            (',' xml_attributes_clause)? (',' expression_wrapper column_alias?)* ')' ('.' general_element_part)?
                         | XMLEXISTS '(' expression_wrapper xml_passing_clause? ')'
                         | XMLPARSE '(' (DOCUMENT | CONTENT) concatenation_wrapper WELLFORMED? ')' ('.' general_element_part)?
                         | XMLPI '(' (NAME id | EVALNAME concatenation_wrapper) (',' concatenation_wrapper)? ')' ('.' general_element_part)?
                         | XMLQUERY '(' concatenation_wrapper xml_passing_clause? RETURNING CONTENT (NULL ON EMPTY)? ')' ('.' general_element_part)?
                         | XMLROOT '(' concatenation_wrapper (',' xmlroot_param_version_part)? (',' xmlroot_param_standalone_part)? ')' ('.' general_element_part)?
                         | XMLSERIALIZE '(' (DOCUMENT | CONTENT) concatenation_wrapper (AS type_spec)?
                           xmlserialize_param_enconding_part? xmlserialize_param_version_part? xmlserialize_param_ident_part? ((HIDE | SHOW) DEFAULTS)? ')'
                           ('.' general_element_part)?
                         | XMLTABLE '(' xml_namespaces_clause? concatenation_wrapper xml_passing_clause? (COLUMNS xml_table_column (',' xml_table_column))? ')'
                           ('.' general_element_part)?
                         ;

over_clause_keyword : AVG | CORR | LAG | LEAD | MAX | MEDIAN | MIN | NTILE | RATIO_TO_REPORT | ROW_NUMBER | SUM | VARIANCE | REGR_ | STDDEV | VAR_ | COVAR_ ;
within_or_over_clause_keyword : CUME_DIST | DENSE_RANK | LISTAGG | PERCENT_RANK | PERCENTILE_CONT | PERCENTILE_DISC | RANK ;
standard_prediction_function_keyword : PREDICTION | PREDICTION_BOUNDS | PREDICTION_COST | PREDICTION_DETAILS | PREDICTION_PROBABILITY | PREDICTION_SET ;
    
over_clause              : OVER '(' query_partition? (order_by windowing_clause?)? ')' ;
windowing_clause         : windowing_type (BETWEEN windowing_elements AND windowing_elements | windowing_elements) ;
windowing_type           : ROWS | RANGE ;
windowing_elements       : UNBOUNDED PRECEDING | CURRENT ROW | concatenation_wrapper (PRECEDING|FOLLOWING) ;
using_clause             : USING ('*' | using_elems) ;
using_elems              : using_elem (',' using_elem)* ;
using_elem               : (IN OUT? | OUT)? select_list_elem ;
collect_order_by_part    : ORDER BY concatenation_wrapper ;
within_or_over_part      : WITHIN GROUP '(' order_by ')' | over_clause ;
cost_matrix_clause       : COST (MODEL AUTO? | '(' cost_class_name (',' cost_class_name)* ')' VALUES expression_list) ;
xml_passing_clause       : PASSING (BY VALUE)? expression_wrapper column_alias? (',' expression_wrapper column_alias?) ;
xml_attributes_clause    : XMLATTRIBUTES '(' (ENTITYESCAPING | NOENTITYESCAPING)? (SCHEMACHECK | NOSCHEMACHECK)?
                           xml_multiuse_expression_element (',' xml_multiuse_expression_element)* ')' ;
xml_namespaces_clause    : XMLNAMESPACES '(' (concatenation_wrapper column_alias)? (',' concatenation_wrapper column_alias)* xml_general_default_part? ')' ;
xml_table_column         : xml_column_name (FOR ORDINALITY | type_spec (PATH concatenation_wrapper)? xml_general_default_part?) ;
xml_general_default_part : DEFAULT concatenation_wrapper ;
xml_multiuse_expression_element : expression (AS (id_expression | EVALNAME concatenation))? ;
xmlroot_param_version_part : VERSION (NO VALUE | expression_wrapper) ;
xmlroot_param_standalone_part : STANDALONE (YES | NO VALUE?) ;
xmlserialize_param_enconding_part : ENCODING concatenation_wrapper ;
xmlserialize_param_version_part : VERSION concatenation_wrapper ;
xmlserialize_param_ident_part : NO INDENT | INDENT (SIZE '=' concatenation_wrapper)? ;

// Commons {{{2

column_alias        : AS? (id | alias_quoted_string) | AS ;
table_alias         : (id | alias_quoted_string) ;
alias_quoted_string : quoted_string ;


xml_column_name
    : id
    | quoted_string
    ;

cost_class_name
    : id
    ;

attribute_name
    : id
    ;

savepoint_name
    : id
    ;

rollback_segment_name
    : id
    ;

table_var_name
    : id
    ;

schema_name
    : id
    ;

parameter_name
    : id
    ;

reference_model_name
    : id
    ;

main_model_name
    : id
    ;

aggregate_function_name
    : id ('.' id_expression)*
    ;

query_name
    : id
    ;

constraint_name
    : id ('.' id_expression)* ('@' link_name)?
    ;

label_name
    : id_expression
    ;

type_name
    : id_expression ('.' id_expression)*
    ;

cursor_name
    : id
    | bind_variable
    ;

link_name
    : id
    ;

column_name
    : id ('.' id_expression)*
    ;

// TODO: FIXME
tableview_name
    : id ('.' id_expression)? 
      ('@' link_name | /*TODO{!(input.LA(2) == SQL92_RESERVED_BY)}?*/ partition_extension_clause)?
    ;

partition_extension_clause
    : (SUBPARTITION | PARTITION) FOR? expression_list
    ;

char_set_name
    : id_expression ('.' id_expression)*
    ;

keep_clause
    : KEEP '(' DENSE_RANK (FIRST | LAST) order_by ')' over_clause?
    ;

function_argument
    : '(' argument? (',' argument )* ')' keep_clause?
    ;

function_argument_analytic
    : '(' (argument respect_or_ignore_nulls?)? (',' argument respect_or_ignore_nulls?)* ')' keep_clause?
    ;

function_argument_modeling
    : '(' column_name (',' (numeric | NULL) (',' (numeric | NULL))?)?
      USING (tableview_name '.' '*' | '*' | expression column_alias? (',' expression column_alias?)*)
      ')' keep_clause?
    ;

respect_or_ignore_nulls
    : (RESPECT | IGNORE) NULLS
    ;

argument
    : (id '=' '>')? expression_wrapper
    ;

type_spec
    : datatype
    | REF? type_name (PERCENT_ROWTYPE | PERCENT_TYPE)?
    ;

datatype
    : native_datatype_element precision_part? (WITH LOCAL? TIME ZONE)?
    | INTERVAL (YEAR | DAY) ('(' expression_wrapper ')')? TO (MONTH | SECOND) ('(' expression_wrapper ')')?
    ;

precision_part
    : '(' numeric (',' numeric)? (CHAR | BYTE)? ')'
    ;

native_datatype_element
    : BINARY_INTEGER
    | PLS_INTEGER
    | NATURAL
    | BINARY_FLOAT
    | BINARY_DOUBLE
    | NATURALN
    | POSITIVE
    | POSITIVEN
    | SIGNTYPE
    | SIMPLE_INTEGER
    | NVARCHAR2
    | DEC
    | INTEGER
    | INT
    | NUMERIC
    | SMALLINT
    | NUMBER
    | DECIMAL 
    | DOUBLE PRECISION?
    | FLOAT
    | REAL
    | NCHAR
    | LONG RAW?
    | CHAR  
    | CHARACTER 
    | VARCHAR2
    | VARCHAR
    | STRING
    | RAW
    | BOOLEAN
    | DATE
    | ROWID
    | UROWID
    | YEAR
    | MONTH
    | DAY
    | HOUR
    | MINUTE
    | SECOND
    | TIMEZONE_HOUR
    | TIMEZONE_MINUTE
    | TIMEZONE_REGION
    | TIMEZONE_ABBR
    | TIMESTAMP
    | TIMESTAMP_UNCONSTRAINED
    | TIMESTAMP_TZ_UNCONSTRAINED
    | TIMESTAMP_LTZ_UNCONSTRAINED
    | YMINTERVAL_UNCONSTRAINED
    | DSINTERVAL_UNCONSTRAINED
    | BFILE
    | BLOB
    | CLOB
    | NCLOB
    | MLSLABEL
    ;

bind_variable
    : (BINDVAR | ':' UNSIGNED_INTEGER)
      (INDICATOR? (BINDVAR | ':' UNSIGNED_INTEGER))?
      ('.' general_element_part)*
    ;

general_element
    : general_element_part ('.' general_element_part)*
    ;

general_element_part
    : (INTRODUCER char_set_name)? id_expression
      ('.' id_expression)* function_argument?
    ;

table_element
    : (INTRODUCER char_set_name)? id_expression ('.' id_expression)*
    ;

// Lexer {{{1

constant
    : TIMESTAMP (quoted_string | bind_variable) (AT TIME ZONE quoted_string)?
    | INTERVAL (quoted_string | bind_variable | general_element_part)
      (DAY | HOUR | MINUTE | SECOND)
      ('(' (UNSIGNED_INTEGER | bind_variable) (',' (UNSIGNED_INTEGER | bind_variable) )? ')')?
      (TO ( DAY | HOUR | MINUTE | SECOND ('(' (UNSIGNED_INTEGER | bind_variable) ')')?))?
    | numeric
    | DATE quoted_string
    | quoted_string
    | NULL
    | TRUE
    | FALSE
    | DBTIMEZONE 
    | SESSIONTIMEZONE
    | MINVALUE
    | MAXVALUE
    | DEFAULT
    ;

numeric
    : UNSIGNED_INTEGER
    | APPROXIMATE_NUM_LIT
    ;

numeric_negative
    : MINUS_SIGN numeric
    ;

quoted_string
    : CHAR_STRING
    //| CHAR_STRING_PERL
    | NATIONAL_CHAR_STRING_LIT
    ;

id
    : (INTRODUCER char_set_name)? id_expression
    ;

id_expression
    : regular_id
    | DELIMITED_ID
    ;

not_equal_op
    : NOT_EQUAL_OP
    | '<' '>'
    | '!' '='
    | '^' '='
    ;

greater_than_or_equals_op
    : '>='
    | '>' '='
    ;

less_than_or_equals_op
    : '<='
    | '<' '='
    ;

concatenation_op
    : '||'
    | '|' '|'
    ;

outer_join_sign
    : '(' '+' ')'
    ;
    
regular_id
    : REGULAR_ID
    | A_LETTER
    | ADD
    | AFTER
    | AGENT
    | AGGREGATE
    //| ALL
    //| ALTER
    | ANALYZE
    //| AND
    //| ANY
    | ARRAY
    // | AS
    //| ASC
    | ASSOCIATE
    | AT
    | ATTRIBUTE
    | AUDIT
    | AUTHID
    | AUTO
    | AUTOMATIC
    | AUTONOMOUS_TRANSACTION
    | BATCH
    | BEFORE
    //| BEGIN
    // | BETWEEN
    | BFILE
    | BINARY_DOUBLE
    | BINARY_FLOAT
    | BINARY_INTEGER
    | BLOB
    | BLOCK
    | BODY
    | BOOLEAN
    | BOTH
    // | BREADTH
    | BULK
    // | BY
    | BYTE
    | C_LETTER
    // | CACHE
    | CALL
    | CANONICAL
    | CASCADE
    //| CASE
    | CAST
    | CHAR
    | CHAR_CS
    | CHARACTER
    //| CHECK
    | CHR
    | CLOB
    | CLOSE
    | CLUSTER
    | COLLECT
    | COLUMNS
    | COMMENT
    | COMMIT
    | COMMITTED
    | COMPATIBILITY
    | COMPILE
    | COMPOUND
    //| CONNECT
    //| CONNECT_BY_ROOT
    | CONSTANT
    | CONSTRAINT
    | CONSTRAINTS
    | CONSTRUCTOR
    | CONTENT
    | CONTEXT
    | CONTINUE
    | CONVERT
    | CORRUPT_XID
    | CORRUPT_XID_ALL
    | COST
    | COUNT
    //| CREATE
    | CROSS
    | CUBE
    //| CURRENT
    | CURRENT_USER
    | CURSOR
    | CUSTOMDATUM
    | CYCLE
    | DATA
    | DATABASE
    //| DATE
    | DAY
    | DB_ROLE_CHANGE
    | DBTIMEZONE
    | DDL
    | DEBUG
    | DEC
    | DECIMAL
    //| DECLARE
    | DECOMPOSE
    | DECREMENT
    //| DEFAULT
    | DEFAULTS
    | DEFERRED
    | DEFINER
    // | DELETE
    // | DEPTH
    //| DESC
    | DETERMINISTIC
    | DIMENSION
    | DISABLE
    | DISASSOCIATE
    //| DISTINCT
    | DOCUMENT
    | DOUBLE
    //| DROP
    | DSINTERVAL_UNCONSTRAINED
    | EACH
    | ELEMENT
    //| ELSE
    //| ELSIF
    | EMPTY
    | ENABLE
    | ENCODING
    //| END
    | ENTITYESCAPING
    | ERR
    | ERRORS
    | ESCAPE
    | EVALNAME
    //| EXCEPTION
    | EXCEPTION_INIT
    | EXCEPTIONS
    | EXCLUDE
    //| EXCLUSIVE
    | EXECUTE
    //| EXISTS
    | EXIT
    | EXPLAIN
    | EXTERNAL
    | EXTRACT
    | FAILURE
    //| FALSE
    //| FETCH
    | FINAL
    | FIRST
    | FIRST_VALUE
    | FLOAT
    | FOLLOWING
    | FOLLOWS
    //| FOR
    | FORALL
    | FORCE
    // | FROM
    | FULL
    | FUNCTION
    //| GOTO
    //| GRANT
    //| GROUP
    | GROUPING
    | HASH
    //| HAVING
    | HIDE
    | HOUR
    //| IF
    | IGNORE
    | IMMEDIATE
    // | IN
    | INCLUDE
    | INCLUDING
    | INCREMENT
    | INDENT
    //| INDEX
    | INDEXED
    | INDICATOR
    | INDICES
    | INFINITE
    | INLINE
    | INNER
    | INOUT
    //| INSERT
    | INSTANTIABLE
    | INSTEAD
    | INT
    | INTEGER
    //| INTERSECT
    | INTERVAL
    // | INTO
    | INVALIDATE
    //| IS
    | ISOLATION
    | ITERATE
    | JAVA
    | JOIN
    | KEEP
    | LANGUAGE
    | LAST
    | LAST_VALUE
    | LEADING
    | LEFT
    | LEVEL
    | LIBRARY
    // | LIKE
    | LIKE2
    | LIKE4
    | LIKEC
    | LIMIT
    | LOCAL
    //| LOCK
    | LOCKED
    | LOG
    | LOGOFF
    | LOGON
    | LONG
    | LOOP
    | MAIN
    | MAP
    | MATCHED
    | MAXVALUE
    | MEASURES
    | MEMBER
    | MERGE
    //| MINUS
    | MINUTE
    | MINVALUE
    | MLSLABEL
    //| MODE
    | MODEL
    | MODIFY
    | MONTH
    | MULTISET
    | NAME
    | NAN
    | NATURAL
    | NATURALN
    | NAV
    | NCHAR
    | NCHAR_CS
    | NCLOB
    | NESTED
    | NEW
    | NO
    | NOAUDIT
    // | NOCACHE
    | NOCOPY
    | NOCYCLE
    | NOENTITYESCAPING
    //| NOMAXVALUE
    //| NOMINVALUE
    | NONE
    // | NOORDER
    | NOSCHEMACHECK
    //| NOT
    //| NOWAIT
    // | NULL
    | NULLS
    | NUMBER
    | NUMERIC
    | NVARCHAR2
    | OBJECT
    //| OF
    | OFF
    | OID
    | OLD
    //| ON
    | ONLY
    | OPEN
    //| OPTION
    //| OR
    | ORADATA
    //| ORDER
    | ORDINALITY
    | OSERROR
    | OUT
    | OUTER
    | OVER
    | OVERRIDING
    | PACKAGE
    | PARALLEL_ENABLE
    | PARAMETERS
    | PARENT
    | PARTITION
    | PASSING
    | PATH
    //| PERCENT_ROWTYPE
    //| PERCENT_TYPE
    | PIPELINED
    //| PIVOT
    | PLAN
    | PLS_INTEGER
    | POSITIVE
    | POSITIVEN
    | PRAGMA
    | PRECEDING
    | PRECISION
    | PRESENT
    //| PRIOR
    //| PROCEDURE
    | RAISE
    | RANGE
    | RAW
    | READ
    | REAL
    | RECORD
    | REF
    | REFERENCE
    | REFERENCING
    | REJECT
    | RELIES_ON
    | RENAME
    | REPLACE
    | RESPECT
    | RESTRICT_REFERENCES
    | RESULT
    | RESULT_CACHE
    | RETURN
    | RETURNING
    | REUSE
    | REVERSE
    //| REVOKE
    | RIGHT
    | ROLLBACK
    | ROLLUP
    | ROW
    | ROWID
    | ROWS
    | RULES
    | SAMPLE
    | SAVE
    | SAVEPOINT
    | SCHEMA
    | SCHEMACHECK
    | SCN
    // | SEARCH
    | SECOND
    | SEED
    | SEGMENT
    // | SELECT
    | SELF
    // | SEQUENCE
    | SEQUENTIAL
    | SERIALIZABLE
    | SERIALLY_REUSABLE
    | SERVERERROR
    | SESSIONTIMEZONE
    | SET
    | SETS
    | SETTINGS
    //| SHARE
    | SHOW
    | SHUTDOWN
    | SIBLINGS
    | SIGNTYPE
    | SIMPLE_INTEGER
    | SINGLE
    //| SIZE
    | SKIP_
    | SMALLINT
    | SNAPSHOT
    | SOME
    | SPECIFICATION
    | SQLDATA
    | SQLERROR
    | STANDALONE
    //| START
    | STARTUP
    | STATEMENT
    | STATEMENT_ID
    | STATIC
    | STATISTICS
    | STRING
    | SUBMULTISET
    | SUBPARTITION
    | SUBSTITUTABLE
    | SUBTYPE
    | SUCCESS
    | SUSPEND
    //| TABLE
    //| THE
    //| THEN
    | TIME
    | TIMESTAMP
    | TIMESTAMP_LTZ_UNCONSTRAINED
    | TIMESTAMP_TZ_UNCONSTRAINED
    | TIMESTAMP_UNCONSTRAINED
    | TIMEZONE_ABBR
    | TIMEZONE_HOUR
    | TIMEZONE_MINUTE
    | TIMEZONE_REGION
    //| TO
    | TRAILING
    | TRANSACTION
    | TRANSLATE
    | TREAT
    | TRIGGER
    | TRIM
    //| TRUE
    | TRUNCATE
    | TYPE
    | UNBOUNDED
    | UNDER
    //| UNION
    //| UNIQUE
    | UNLIMITED
    //| UNPIVOT
    | UNTIL
    //| UPDATE
    | UPDATED
    | UPSERT
    | UROWID
    | USE
    //| USING
    | VALIDATE
    | VALUE
    //| VALUES
    | VARCHAR
    | VARCHAR2
    | VARIABLE
    | VARRAY
    | VARYING
    | VERSION
    | VERSIONS
    | WAIT
    | WARNING
    | WELLFORMED
    // | WHEN
    | WHENEVER
    // | WHERE
    | WHILE
    //| WITH
    | WITHIN
    | WORK
    | WRITE
    | XML
    | XMLAGG
    | XMLATTRIBUTES
    | XMLCAST
    | XMLCOLATTVAL
    | XMLELEMENT
    | XMLEXISTS
    | XMLFOREST
    | XMLNAMESPACES
    | XMLPARSE
    | XMLPI
    | XMLQUERY
    | XMLROOT
    | XMLSERIALIZE
    | XMLTABLE
    | YEAR
    | YES
    | YMINTERVAL_UNCONSTRAINED
    | ZONE
    | PREDICTION
    | PREDICTION_BOUNDS
    | PREDICTION_COST
    | PREDICTION_DETAILS
    | PREDICTION_PROBABILITY
    | PREDICTION_SET
    | CUME_DIST
    | DENSE_RANK
    | LISTAGG
    | PERCENT_RANK
    | PERCENTILE_CONT
    | PERCENTILE_DISC
    | RANK
    | AVG
    | CORR
    | LAG
    | LEAD
    | MAX
    | MEDIAN
    | MIN
    | NTILE
    | RATIO_TO_REPORT
    | ROW_NUMBER
    | SUM
    | VARIANCE
    | REGR_
    | STDDEV
    | VAR_
    | COVAR_
    ;

A_LETTER:                     A;
ADD:                          A D D;
AFTER:                        A F T E R;
AGENT:                        A G E N T;
AGGREGATE:                    A G G R E G A T E;
ALL:                          A L L;
ALTER:                        A L T E R;
ANALYZE:                      A N A L Y Z E;
AND:                          A N D;
ANY:                          A N Y;
ARRAY:                        A R R A Y;
AS:                           A S;
ASC:                          A S C;
ASSOCIATE:                    A S S O C I A T E;
AT:                           A T;
ATTRIBUTE:                    A T T R I B U T E;
AUDIT:                        A U D I T;
AUTHID:                       A U T H I D;
AUTO:                         A U T O;
AUTOMATIC:                    A U T O M A T I C;
AUTONOMOUS_TRANSACTION:       A U T O N O M O U S '_' T R A N S A C T I O N;
BATCH:                        B A T C H;
BEFORE:                       B E F O R E;
BEGIN:                        B E G I N;
BETWEEN:                      B E T W E E N;
BFILE:                        B F I L E;
BINARY_DOUBLE:                B I N A R Y '_' D O U B L E;
BINARY_FLOAT:                 B I N A R Y '_' F L O A T;
BINARY_INTEGER:               B I N A R Y '_' I N T E G E R;
BLOB:                         B L O B;
BLOCK:                        B L O C K;
BODY:                         B O D Y;
BOOLEAN:                      B O O L E A N;
BOTH:                         B O T H;
BREADTH:                      B R E A D T H;
BULK:                         B U L K;
BY:                           B Y;
BYTE:                         B Y T E;
C_LETTER:                     C;
CACHE:                        C A C H E;
CALL:                         C A L L;
CANONICAL:                    C A N O N I C A L;
CASCADE:                      C A S C A D E;
CASE:                         C A S E;
CAST:                         C A S T;
CHAR:                         C H A R;
CHAR_CS:                      C H A R '_' C S;
CHARACTER:                    C H A R A C T E R;
CHECK:                        C H E C K;
CHR:                          C H R;
CLOB:                         C L O B;
CLOSE:                        C L O S E;
CLUSTER:                      C L U S T E R;
COLLECT:                      C O L L E C T;
COLUMNS:                      C O L U M N S;
COMMENT:                      C O M M E N T;
COMMIT:                       C O M M I T;
COMMITTED:                    C O M M I T T E D;
COMPATIBILITY:                C O M P A T I B I L I T Y;
COMPILE:                      C O M P I L E;
COMPOUND:                     C O M P O U N D;
CONNECT:                      C O N N E C T;
CONNECT_BY_ROOT:              C O N N E C T '_' B Y '_' R O O T;
CONSTANT:                     C O N S T A N T;
CONSTRAINT:                   C O N S T R A I N T;
CONSTRAINTS:                  C O N S T R A I N T S;
CONSTRUCTOR:                  C O N S T R U C T O R;
CONTENT:                      C O N T E N T;
CONTEXT:                      C O N T E X T;
CONTINUE:                     C O N T I N U E;
CONVERT:                      C O N V E R T;
CORRUPT_XID:                  C O R R U P T '_' X I D;
CORRUPT_XID_ALL:              C O R R U P T '_' X I D '_' A L L;
COST:                         C O S T;
COUNT:                        C O U N T;
CREATE:                       C R E A T E;
CROSS:                        C R O S S;
CUBE:                         C U B E;
CURRENT:                      C U R R E N T;
CURRENT_USER:                 C U R R E N T '_' U S E R;
CURSOR:                       C U R S O R;
CUSTOMDATUM:                  C U S T O M D A T U M;
CYCLE:                        C Y C L E;
DATA:                         D A T A;
DATABASE:                     D A T A B A S E;
DATE:                         D A T E;
DAY:                          D A Y;
DB_ROLE_CHANGE:               D B '_' R O L E '_' C H A N G E;
DBTIMEZONE:                   D B T I M E Z O N E;
DDL:                          D D L;
DEBUG:                        D E B U G;
DEC:                          D E C;
DECIMAL:                      D E C I M A L;
DECLARE:                      D E C L A R E;
DECOMPOSE:                    D E C O M P O S E;
DECREMENT:                    D E C R E M E N T;
DEFAULT:                      D E F A U L T;
DEFAULTS:                     D E F A U L T S;
DEFERRED:                     D E F E R R E D;
DEFINER:                      D E F I N E R;
DELETE:                       D E L E T E;
DEPTH:                        D E P T H;
DESC:                         D E S C;
DETERMINISTIC:                D E T E R M I N I S T I C;
DIMENSION:                    D I M E N S I O N;
DISABLE:                      D I S A B L E;
DISASSOCIATE:                 D I S A S S O C I A T E;
DISTINCT:                     D I S T I N C T;
DOCUMENT:                     D O C U M E N T;
DOUBLE:                       D O U B L E;
DROP:                         D R O P;
DSINTERVAL_UNCONSTRAINED:     D S I N T E R V A L '_' U N C O N S T R A I N E D;
EACH:                         E A C H;
ELEMENT:                      E L E M E N T;
ELSE:                         E L S E;
ELSIF:                        E L S I F;
EMPTY:                        E M P T Y;
ENABLE:                       E N A B L E;
ENCODING:                     E N C O D I N G;
END:                          E N D;
ENTITYESCAPING:               E N T I T Y E S C A P I N G;
ERR:                          E R R;
ERRORS:                       E R R O R S;
ESCAPE:                       E S C A P E;
EVALNAME:                     E V A L N A M E;
EXCEPTION:                    E X C E P T I O N;
EXCEPTION_INIT:               E X C E P T I O N '_' I N I T;
EXCEPTIONS:                   E X C E P T I O N S;
EXCLUDE:                      E X C L U D E;
EXCLUSIVE:                    E X C L U S I V E;
EXECUTE:                      E X E C U T E;
EXISTS:                       E X I S T S;
EXIT:                         E X I T;
EXPLAIN:                      E X P L A I N;
EXTERNAL:                     E X T E R N A L;
EXTRACT:                      E X T R A C T;
FAILURE:                      F A I L U R E;
FALSE:                        F A L S E;
FETCH:                        F E T C H;
FINAL:                        F I N A L;
FIRST:                        F I R S T;
FIRST_VALUE:                  F I R S T '_' V A L U E;
FLOAT:                        F L O A T;
FOLLOWING:                    F O L L O W I N G;
FOLLOWS:                      F O L L O W S;
FOR:                          F O R;
FORALL:                       F O R A L L;
FORCE:                        F O R C E;
FROM:                         F R O M;
FULL:                         F U L L;
FUNCTION:                     F U N C T I O N;
GOTO:                         G O T O;
GRANT:                        G R A N T;
GROUP:                        G R O U P;
GROUPING:                     G R O U P I N G;
HASH:                         H A S H;
HAVING:                       H A V I N G;
HIDE:                         H I D E;
HOUR:                         H O U R;
IF:                           I F;
IGNORE:                       I G N O R E;
IMMEDIATE:                    I M M E D I A T E;
IN:                           I N;
INCLUDE:                      I N C L U D E;
INCLUDING:                    I N C L U D I N G;
INCREMENT:                    I N C R E M E N T;
INDENT:                       I N D E N T;
INDEX:                        I N D E X;
INDEXED:                      I N D E X E D;
INDICATOR:                    I N D I C A T O R;
INDICES:                      I N D I C E S;
INFINITE:                     I N F I N I T E;
INLINE:                       I N L I N E;
INNER:                        I N N E R;
INOUT:                        I N O U T;
INSERT:                       I N S E R T;
INSTANTIABLE:                 I N S T A N T I A B L E;
INSTEAD:                      I N S T E A D;
INT:                          I N T;
INTEGER:                      I N T E G E R;
INTERSECT:                    I N T E R S E C T;
INTERVAL:                     I N T E R V A L;
INTO:                         I N T O;
INVALIDATE:                   I N V A L I D A T E;
IS:                           I S;
ISOLATION:                    I S O L A T I O N;
ITERATE:                      I T E R A T E;
JAVA:                         J A V A;
JOIN:                         J O I N;
KEEP:                         K E E P;
LANGUAGE:                     L A N G U A G E;
LAST:                         L A S T;
LAST_VALUE:                   L A S T '_' V A L U E;
LEADING:                      L E A D I N G;
LEFT:                         L E F T;
LEVEL:                        L E V E L;
LIBRARY:                      L I B R A R Y;
LIKE:                         L I K E;
LIKE2:                        L I K E '2';
LIKE4:                        L I K E '4';
LIKEC:                        L I K E C;
LIMIT:                        L I M I T;
LOCAL:                        L O C A L;
LOCK:                         L O C K;
LOCKED:                       L O C K E D;
LOG:                          L O G;
LOGOFF:                       L O G O F F;
LOGON:                        L O G O N;
LONG:                         L O N G;
LOOP:                         L O O P;
MAIN:                         M A I N;
MAP:                          M A P;
MATCHED:                      M A T C H E D;
MAXVALUE:                     M A X V A L U E;
MEASURES:                     M E A S U R E S;
MEMBER:                       M E M B E R;
MERGE:                        M E R G E;
MINUS:                        M I N U S;
MINUTE:                       M I N U T E;
MINVALUE:                     M I N V A L U E;
MLSLABEL:                     M L S L A B E L;
MODE:                         M O D E;
MODEL:                        M O D E L;
MODIFY:                       M O D I F Y;
MONTH:                        M O N T H;
MULTISET:                     M U L T I S E T;
NAME:                         N A M E;
NAN:                          N A N;
NATURAL:                      N A T U R A L;
NATURALN:                     N A T U R A L N;
NAV:                          N A V;
NCHAR:                        N C H A R;
NCHAR_CS:                     N C H A R '_' C S;
NCLOB:                        N C L O B;
NESTED:                       N E S T E D;
NEW:                          N E W;
NO:                           N O;
NOAUDIT:                      N O A U D I T;
NOCACHE:                      N O C A C H E;
NOCOPY:                       N O C O P Y;
NOCYCLE:                      N O C Y C L E;
NOENTITYESCAPING:             N O E N T I T Y E S C A P I N G;
NOMAXVALUE:                   N O M A X V A L U E;
NOMINVALUE:                   N O M I N V A L U E;
NONE:                         N O N E;
NOORDER:                      N O O R D E R;
NOSCHEMACHECK:                N O S C H E M A C H E C K;
NOT:                          N O T;
NOWAIT:                       N O W A I T;
NULL:                         N U L L;
NULLS:                        N U L L S;
NUMBER:                       N U M B E R;
NUMERIC:                      N U M E R I C;
NVARCHAR2:                    N V A R C H A R '2';
OBJECT:                       O B J E C T;
OF:                           O F;
OFF:                          O F F;
OID:                          O I D;
OLD:                          O L D;
ON:                           O N;
ONLY:                         O N L Y;
OPEN:                         O P E N;
OPTION:                       O P T I O N;
OR:                           O R;
ORADATA:                      O R A D A T A;
ORDER:                        O R D E R;
ORDINALITY:                   O R D I N A L I T Y;
OSERROR:                      O S E R R O R;
OUT:                          O U T;
OUTER:                        O U T E R;
OVER:                         O V E R;
OVERRIDING:                   O V E R R I D I N G;
PACKAGE:                      P A C K A G E;
PARALLEL_ENABLE:              P A R A L L E L '_' E N A B L E;
PARAMETERS:                   P A R A M E T E R S;
PARENT:                       P A R E N T;
PARTITION:                    P A R T I T I O N;
PASSING:                      P A S S I N G;
PATH:                         P A T H;
PERCENT_ROWTYPE:              '%' R O W T Y P E;
PERCENT_TYPE:                 '%' T Y P E;
PIPELINED:                    P I P E L I N E D;
PIVOT:                        P I V O T;
PLAN:                         P L A N;
PLS_INTEGER:                  P L S '_' I N T E G E R;
POSITIVE:                     P O S I T I V E;
POSITIVEN:                    P O S I T I V E N;
PRAGMA:                       P R A G M A;
PRECEDING:                    P R E C E D I N G;
PRECISION:                    P R E C I S I O N;
PRESENT:                      P R E S E N T;
PRIOR:                        P R I O R;
PROCEDURE:                    P R O C E D U R E;
RAISE:                        R A I S E;
RANGE:                        R A N G E;
RAW:                          R A W;
READ:                         R E A D;
REAL:                         R E A L;
RECORD:                       R E C O R D;
REF:                          R E F;
REFERENCE:                    R E F E R E N C E;
REFERENCING:                  R E F E R E N C I N G;
REJECT:                       R E J E C T;
RELIES_ON:                    R E L I E S '_' O N;
RENAME:                       R E N A M E;
REPLACE:                      R E P L A C E;
RESPECT:                      R E S P E C T;
RESTRICT_REFERENCES:          R E S T R I C T '_' R E F E R E N C E S;
RESULT:                       R E S U L T;
RESULT_CACHE:                 R E S U L T '_' C A C H E;
RETURN:                       R E T U R N;
RETURNING:                    R E T U R N I N G;
REUSE:                        R E U S E;
REVERSE:                      R E V E R S E;
REVOKE:                       R E V O K E;
RIGHT:                        R I G H T;
ROLLBACK:                     R O L L B A C K;
ROLLUP:                       R O L L U P;
ROW:                          R O W;
ROWID:                        R O W I D;
ROWS:                         R O W S;
RULES:                        R U L E S;
SAMPLE:                       S A M P L E;
SAVE:                         S A V E;
SAVEPOINT:                    S A V E P O I N T;
SCHEMA:                       S C H E M A;
SCHEMACHECK:                  S C H E M A C H E C K;
SCN:                          S C N;
SEARCH:                       S E A R C H;
SECOND:                       S E C O N D;
SEED:                         S E E D;
SEGMENT:                      S E G M E N T;
SELECT:                       S E L E C T;
SELF:                         S E L F;
SEQUENCE:                     S E Q U E N C E;
SEQUENTIAL:                   S E Q U E N T I A L;
SERIALIZABLE:                 S E R I A L I Z A B L E;
SERIALLY_REUSABLE:            S E R I A L L Y '_' R E U S A B L E;
SERVERERROR:                  S E R V E R E R R O R;
SESSIONTIMEZONE:              S E S S I O N T I M E Z O N E;
SET:                          S E T;
SETS:                         S E T S;
SETTINGS:                     S E T T I N G S;
SHARE:                        S H A R E;
SHOW:                         S H O W;
SHUTDOWN:                     S H U T D O W N;
SIBLINGS:                     S I B L I N G S;
SIGNTYPE:                     S I G N T Y P E;
SIMPLE_INTEGER:               S I M P L E '_' I N T E G E R;
SINGLE:                       S I N G L E;
SIZE:                         S I Z E;
SKIP_:                        S K I P;
SMALLINT:                     S M A L L I N T;
SNAPSHOT:                     S N A P S H O T;
SOME:                         S O M E;
SPECIFICATION:                S P E C I F I C A T I O N;
SQLDATA:                      S Q L D A T A;
SQLERROR:                     S Q L E R R O R;
STANDALONE:                   S T A N D A L O N E;
START:                        S T A R T;
STARTUP:                      S T A R T U P;
STATEMENT:                    S T A T E M E N T;
STATEMENT_ID:                 S T A T E M E N T '_' I D;
STATIC:                       S T A T I C;
STATISTICS:                   S T A T I S T I C S;
STRING:                       S T R I N G;
SUBMULTISET:                  S U B M U L T I S E T;
SUBPARTITION:                 S U B P A R T I T I O N;
SUBSTITUTABLE:                S U B S T I T U T A B L E;
SUBTYPE:                      S U B T Y P E;
SUCCESS:                      S U C C E S S;
SUSPEND:                      S U S P E N D;
TABLE:                        T A B L E;
THE:                          T H E;
THEN:                         T H E N;
TIME:                         T I M E;
TIMESTAMP:                    T I M E S T A M P;
TIMESTAMP_LTZ_UNCONSTRAINED:  T I M E S T A M P '_' L T Z '_' U N C O N S T R A I N E D;
TIMESTAMP_TZ_UNCONSTRAINED:   T I M E S T A M P '_' T Z '_' U N C O N S T R A I N E D;
TIMESTAMP_UNCONSTRAINED:      T I M E S T A M P '_' U N C O N S T R A I N E D;
TIMEZONE_ABBR:                T I M E Z O N E '_' A B B R;
TIMEZONE_HOUR:                T I M E Z O N E '_' H O U R;
TIMEZONE_MINUTE:              T I M E Z O N E '_' M I N U T E;
TIMEZONE_REGION:              T I M E Z O N E '_' R E G I O N;
TO:                           T O;
TRAILING:                     T R A I L I N G;
TRANSACTION:                  T R A N S A C T I O N;
TRANSLATE:                    T R A N S L A T E;
TREAT:                        T R E A T;
TRIGGER:                      T R I G G E R;
TRIM:                         T R I M;
TRUE:                         T R U E;
TRUNCATE:                     T R U N C A T E;
TYPE:                         T Y P E;
UNBOUNDED:                    U N B O U N D E D;
UNDER:                        U N D E R;
UNION:                        U N I O N;
UNIQUE:                       U N I Q U E;
UNLIMITED:                    U N L I M I T E D;
UNPIVOT:                      U N P I V O T;
UNTIL:                        U N T I L;
UPDATE:                       U P D A T E;
UPDATED:                      U P D A T E D;
UPSERT:                       U P S E R T;
UROWID:                       U R O W I D;
USE:                          U S E;
USING:                        U S I N G;
VALIDATE:                     V A L I D A T E;
VALUE:                        V A L U E;
VALUES:                       V A L U E S;
VARCHAR:                      V A R C H A R;
VARCHAR2:                     V A R C H A R '2';
VARIABLE:                     V A R I A B L E;
VARRAY:                       V A R R A Y;
VARYING:                      V A R Y I N G;
VERSION:                      V E R S I O N;
VERSIONS:                     V E R S I O N S;
WAIT:                         W A I T;
WARNING:                      W A R N I N G;
WELLFORMED:                   W E L L F O R M E D;
WHEN:                         W H E N;
WHENEVER:                     W H E N E V E R;
WHERE:                        W H E R E;
WHILE:                        W H I L E;
WITH:                         W I T H;
WITHIN:                       W I T H I N;
WORK:                         W O R K;
WRITE:                        W R I T E;
XML:                          X M L;
XMLAGG:                       X M L A G G;
XMLATTRIBUTES:                X M L A T T R I B U T E S;
XMLCAST:                      X M L C A S T;
XMLCOLATTVAL:                 X M L C O L A T T V A L;
XMLELEMENT:                   X M L E L E M E N T;
XMLEXISTS:                    X M L E X I S T S;
XMLFOREST:                    X M L F O R E S T;
XMLNAMESPACES:                X M L N A M E S P A C E S;
XMLPARSE:                     X M L P A R S E;
XMLPI:                        X M L P I;
XMLQUERY:                     X M L Q U E R Y;
XMLROOT:                      X M L R O O T;
XMLSERIALIZE:                 X M L S E R I A L I Z E;
XMLTABLE:                     X M L T A B L E;
YEAR:                         Y E A R;
YES:                          Y E S;
YMINTERVAL_UNCONSTRAINED:     Y M I N T E R V A L '_' U N C O N S T R A I N E D;
ZONE:                         Z O N E;

PREDICTION:                   P R E D I C T I O N;
PREDICTION_BOUNDS:            P R E D I C T I O N '_' B O U N D S;
PREDICTION_COST:              P R E D I C T I O N '_' C O S T;
PREDICTION_DETAILS:           P R E D I C T I O N '_' D E T A I L S;
PREDICTION_PROBABILITY:       P R E D I C T I O N '_' P R O B A B I L I T Y;
PREDICTION_SET:               P R E D I C T I O N '_' S E T;
                              
CUME_DIST:                    C U M E '_' D I S T;
DENSE_RANK:                   D E N S E '_' R A N K;
LISTAGG:                      L I S T A G G;
PERCENT_RANK:                 P E R C E N T '_' R A N K;
PERCENTILE_CONT:              P E R C E N T I L E '_' C O N T;
PERCENTILE_DISC:              P E R C E N T I L E '_' D I S C;
RANK:                         R A N K;
                              
AVG:                          A V G;
CORR:                         C O R R;
LAG:                          L A G;
LEAD:                         L E A D;
MAX:                          M A X;
MEDIAN:                       M E D I A N;
MIN:                          M I N;
NTILE:                        N T I L E;
RATIO_TO_REPORT:              R A T I O '_' T O '_' R  E P O R T;
ROW_NUMBER:                   R O W '_' N U M B E R;
SUM:                          S U M;
VARIANCE:                     V A R I A N C E;
REGR_:                        R E G R '_';
STDDEV:                       S T D D E V;
VAR_:                         V A R '_';
COVAR_:                       C O V A R '_';

fragment A: [aA];
fragment B: [bB];
fragment C: [cC];
fragment D: [dD];
fragment E: [eE];
fragment F: [fF];
fragment G: [gG];
fragment H: [hH];
fragment I: [iI];
fragment J: [jJ];
fragment K: [kK];
fragment L: [lL];
fragment M: [mM];
fragment N: [nN];
fragment O: [oO];
fragment P: [pP];
fragment Q: [qQ];
fragment R: [rR];
fragment S: [sS];
fragment T: [tT];
fragment U: [uU];
fragment V: [vV];
fragment W: [wW];
fragment X: [xX];
fragment Y: [yY];
fragment Z: [zZ];

/*FOR_NOTATION
    :    UNSIGNED_INTEGER
        {state.type = UNSIGNED_INTEGER; emit(); advanceInput();}
        '..'
        {state.type = DOUBLE_PERIOD; emit(); advanceInput();}
        UNSIGNED_INTEGER
        {state.type = UNSIGNED_INTEGER; emit(); advanceInput(); $channel=HIDDEN;}
    ;
*/

//{ Rule #358 <NATIONAL_CHAR_STRING_LIT> - subtoken typecast in <REGULAR_ID>, it also incorporates <character_representation>
//  Lowercase 'n' is a usual addition to the standard
NATIONAL_CHAR_STRING_LIT
    : N '\'' (~('\'' | '\r' | '\n' ) | '\'' '\'' | NEWLINE)* '\''
    ;
//}

//{ Rule #040 <BIT_STRING_LIT> - subtoken typecast in <REGULAR_ID>
//  Lowercase 'b' is a usual addition to the standard
BIT_STRING_LIT
    : B ('\'' ('0' | '1')* '\'' /*SEPARATOR?*/ )+
    ;
//}


//{ Rule #284 <HEX_STRING_LIT> - subtoken typecast in <REGULAR_ID>
//  Lowercase 'x' is a usual addition to the standard
HEX_STRING_LIT
    : X ('\'' ('a'..'f' | 'A'..'F' | '0'..'9')* '\'' /*SEPARATOR?*/ )+ 
    ;
//}

DOUBLE_PERIOD
    : '.' '.'
    ;

PERIOD
    : '.'
    ;

//{ Rule #238 <EXACT_NUM_LIT> 
//  This rule is a bit tricky - it resolves the ambiguity with <PERIOD> 
//  It als44o incorporates <mantisa> and <exponent> for the <APPROXIMATE_NUM_LIT>
//  Rule #501 <signed_integer> was incorporated directly in the token <APPROXIMATE_NUM_LIT>
//  See also the rule #617 <unsigned_num_lit>
/*
    : (
            UNSIGNED_INTEGER
            ( '.' UNSIGNED_INTEGER
            | {$type = UNSIGNED_INTEGER;}
            ) ( E ('+' | '-')? UNSIGNED_INTEGER {$type = APPROXIMATE_NUM_LIT;} )?
    | '.' UNSIGNED_INTEGER ( E ('+' | '-')? UNSIGNED_INTEGER {$type = APPROXIMATE_NUM_LIT;} )?
    )
    (D | F)?
    ;*/
//}

UNSIGNED_INTEGER: UNSIGNED_INTEGER_FRAGMENT;
APPROXIMATE_NUM_LIT: FLOAT_FRAGMENT (('e'|'E') ('+'|'-')? (FLOAT_FRAGMENT | UNSIGNED_INTEGER_FRAGMENT))? (D | F)?;


//{ Rule #--- <CHAR_STRING> is a base for Rule #065 <char_string_lit> , it incorporates <character_representation>
//  and a superfluous subtoken typecasting of the "QUOTE"
CHAR_STRING
    : '\'' (~('\'' | '\r' | '\n') | '\'' '\'' | NEWLINE)* '\''
    ;
//}

// Perl-style quoted string, see Oracle SQL reference, chapter String Literals
CHAR_STRING_PERL    : Q ( QS_ANGLE | QS_BRACE | QS_BRACK | QS_PAREN | QS_HASH /*| QS_OTHER*/) -> type(CHAR_STRING);
fragment QUOTE      : '\'' ;
fragment QS_ANGLE   : QUOTE '<' .*? '>' QUOTE ;
fragment QS_BRACE   : QUOTE '{' .*? '}' QUOTE ;
fragment QS_BRACK   : QUOTE '[' .*? ']' QUOTE ;
fragment QS_PAREN   : QUOTE '(' .*? ')' QUOTE ;
fragment QS_HASH    : QUOTE '#' .*? '#' QUOTE ;
fragment QS_EXCL    : QUOTE '!' .*? '!' QUOTE ;

fragment QS_OTHER_CH: ~('<' | '{' | '[' | '(' | ' ' | '\t' | '\n' | '\r');
/*fragment QS_OTHER:
    QUOTE QS_OTHER_CH { delimeter = _input.La(-1); }
    (. { _input.La(-1) != delimeter }? )* QS_OTHER_CH QUOTE;*/
/*fragment QS_OTHER
//    For C target we have to preserve case sensitivity.
//		@declarations {
//    		ANTLR3_UINT32 (*oldLA)(struct ANTLR3_INT_STREAM_struct *, ANTLR3_INT32);
//		}
//		@init {
//			oldLA = INPUT->istream->_LA;
//            INPUT->setUcaseLA(INPUT, ANTLR3_FALSE);
//		}
		:
		QUOTE delimiter=QS_OTHER_CH
// JAVA Syntax 
    ( { input.LT(1) != $delimiter.text.charAt(0) || ( input.LT(1) == $delimiter.text.charAt(0) && input.LT(2) != '\'') }? => . )*
    ( { input.LT(1) == $delimiter.text.charAt(0) && input.LT(2) == '\'' }? => . ) QUOTE
		;*/

//{ Rule #163 <DELIMITED_ID>
DELIMITED_ID
    : '"' (~('"' | '\r' | '\n') | '"' '"')+ '"' 
    ;
//}

//{ Rule #546 <SQL_SPECIAL_CHAR> was split into single rules
PERCENT
    : '%'
    ;

AMPERSAND
    : '&'
    ;

LEFT_PAREN
    : '('
    ;

RIGHT_PAREN
    : ')'
    ;

DOUBLE_ASTERISK
    : '**'
    ;

ASTERISK
    : '*'
    ;

PLUS_SIGN
    : '+'
    ;
    
MINUS_SIGN
    : '-'
    ;

COMMA
    : ','
    ;

SOLIDUS
    : '/'
    ; 

AT_SIGN
    : '@'
    ;

ASSIGN_OP
    : ':='
    ;
    
// See OCI reference for more information about this
BINDVAR
    : ':' SIMPLE_LETTER  (SIMPLE_LETTER | '0' .. '9' | '_')*
    | ':' DELIMITED_ID  // not used in SQL but spotted in v$sqltext when using cursor_sharing
    | ':' UNSIGNED_INTEGER
    | QUESTION_MARK // not in SQL, not in Oracle, not in OCI, use this for JDBC
    ;

COLON
    : ':'
    ;

SEMICOLON
    : ';'
    ;

LESS_THAN_OR_EQUALS_OP
    : '<='
    ;

LESS_THAN_OP
    : '<'
    ;

GREATER_THAN_OR_EQUALS_OP
    : '>='
    ;

NOT_EQUAL_OP
    : '!='
    | '<>'
    | '^='
    | '~='
    ;
    
CARRET_OPERATOR_PART
    : '^'
    ;

TILDE_OPERATOR_PART
    : '~'
    ;

EXCLAMATION_OPERATOR_PART
    : '!'
    ;

GREATER_THAN_OP
    : '>'
    ;

fragment
QUESTION_MARK
    : '?'
    ;

// protected UNDERSCORE : '_' SEPARATOR ; // subtoken typecast within <INTRODUCER>
CONCATENATION_OP
    : '||'
    ;

VERTICAL_BAR
    : '|'
    ;

EQUALS_OP
    : '='
    ;

//{ Rule #532 <SQL_EMBDD_LANGUAGE_CHAR> was split into single rules:
LEFT_BRACKET
    : '['
    ;

RIGHT_BRACKET
    : ']'
    ;

//}

//{ Rule #319 <INTRODUCER>
INTRODUCER
    : '_' //(SEPARATOR {$type = UNDERSCORE;})?
    ;

//{ Rule #479 <SEPARATOR>
//  It was originally a protected rule set to be filtered out but the <COMMENT> and <'-'> clashed. 
/*SEPARATOR
    : '-' -> type('-')
    | COMMENT -> channel(HIDDEN)
    | (SPACE | NEWLINE)+ -> channel(HIDDEN)
    ;*/
//}

SPACES
    : [ \t\r\n]+ -> skip
    ;
    
//{ Rule #504 <SIMPLE_LETTER> - simple_latin _letter was generalised into SIMPLE_LETTER
//  Unicode is yet to be implemented - see NSF0
fragment
SIMPLE_LETTER
    : 'a'..'z'
    | 'A'..'Z'
    ;
//}

//  Rule #176 <DIGIT> was incorporated by <UNSIGNED_INTEGER> 
//{ Rule #615 <UNSIGNED_INTEGER> - subtoken typecast in <EXACT_NUM_LIT> 
fragment
UNSIGNED_INTEGER_FRAGMENT
    : ('0'..'9')+ 
    ;
//}

fragment
FLOAT_FRAGMENT
    : UNSIGNED_INTEGER* '.'? UNSIGNED_INTEGER+
    ;

//{ Rule #097 <COMMENT>
SINGLE_LINE_COMMENT: '--' ( ~('\r' | '\n') )* (NEWLINE|EOF) -> channel(HIDDEN);
MULTI_LINE_COMMENT: '/*' .*? '*/' -> channel(HIDDEN);

// SQL*Plus prompt
// TODO should be grammar rule, but tricky to implement
PROMPT
	: 'prompt' SPACE ( ~('\r' | '\n') )* (NEWLINE|EOF)
	;

//{ Rule #360 <NEWLINE>
fragment
NEWLINE: '\r'? '\n';
    
fragment
SPACE: [ \t];

//{ Rule #442 <REGULAR_ID> additionally encapsulates a few STRING_LITs.
//  Within testLiterals all reserved and non-reserved words are being resolved

SQL92_RESERVED_ALL
    : 'all'
    ;

SQL92_RESERVED_ALTER
    : 'alter'
    ;

SQL92_RESERVED_AND
    : 'and'
    ;

SQL92_RESERVED_ANY
    : 'any'
    ;

SQL92_RESERVED_AS
    : 'as'
    ;

SQL92_RESERVED_ASC
    : 'asc'
    ;

//SQL92_RESERVED_AT
//    : 'at'
//    ;

SQL92_RESERVED_BEGIN
    : 'begin'
    ;

SQL92_RESERVED_BETWEEN
    : 'between'
    ;

SQL92_RESERVED_BY
    : 'by'
    ;

SQL92_RESERVED_CASE
    : 'case'
    ;

SQL92_RESERVED_CHECK
    : 'check'
    ;

PLSQL_RESERVED_CLUSTERS
    : 'clusters'
    ;

PLSQL_RESERVED_COLAUTH
    : 'colauth'
    ;

PLSQL_RESERVED_COMPRESS
    : 'compress'
    ;

SQL92_RESERVED_CONNECT
    : 'connect'
    ;

//PLSQL_NON_RESERVED_COLUMNS
//    : 'columns'
//    ;

PLSQL_NON_RESERVED_CONNECT_BY_ROOT
    : 'connect_by_root'
    ;

PLSQL_RESERVED_CRASH
    : 'crash'
    ;

SQL92_RESERVED_CREATE
    : 'create'
    ;

SQL92_RESERVED_CURRENT
    : 'current'
    ;

SQL92_RESERVED_CURSOR
    : 'cursor'
    ;

SQL92_RESERVED_DATE
    : 'date'
    ;

SQL92_RESERVED_DECLARE
    : 'declare'
    ;

SQL92_RESERVED_DEFAULT
    : 'default'
    ;

SQL92_RESERVED_DELETE
    : 'delete'
    ;

SQL92_RESERVED_DESC
    : 'desc'
    ;

SQL92_RESERVED_DISTINCT
    : 'distinct'
    ;

SQL92_RESERVED_DROP
    : 'drop'
    ;

SQL92_RESERVED_ELSE
    : 'else'
    ;

SQL92_RESERVED_END
    : 'end'
    ;

SQL92_RESERVED_EXCEPTION
    : 'exception'
/* TODO    // "exception" is a keyword only withing the contex of the PL/SQL language
    // while it can be an identifier(column name, table name) in SQL
    // "exception" is a keyword if and only it is followed by "when"
    {
    $e.setType(SQL92_RESERVED_EXCEPTION);
    emit($e);
    advanceInput();

    $type = Token.INVALID_TOKEN_TYPE;
    int markModel = input.mark();

    // Now loop over next Tokens in the input and eventually set Token's type to REGULAR_ID

    // Subclassed version will return NULL unless EOF is reached.
    // nextToken either returns NULL => then the next token is put into the queue tokenBuffer
    // or it returns Token.EOF, then nothing is put into the queue
    Token t1 = super.nextToken();
    {    // This "if" handles the situation when the "model" is the last text in the input.
        if( t1 != null && t1.getType() == Token.EOF)
        {
             $e.setType(REGULAR_ID);
        } else {
             t1 = tokenBuffer.pollLast(); // "withdraw" the next token from the queue
             while(true)
             {
                 if(t1.getType() == EOF)   // is it EOF?
                 {
                     $e.setType(REGULAR_ID);
                     break;
                 }

                 if(t1.getChannel() == HIDDEN) // is it a white space? then advance to the next token
                 {
                     t1 = super.nextToken(); if( t1 == null) { t1 = tokenBuffer.pollLast(); };
                     continue;
                 }

                 if( t1.getType() != SQL92_RESERVED_WHEN && t1.getType() != SEMICOLON) // is something other than "when"
                 {
                     $e.setType(REGULAR_ID);
                     break;
                 }

                 break; // we are in the model_clase do not rewrite anything
              } // while true
         } // else if( t1 != null && t1.getType() == Token.EOF)
    }
    input.rewind(markModel);
    }*/
    ;

PLSQL_RESERVED_EXCLUSIVE
    : 'exclusive'
    ;

SQL92_RESERVED_EXISTS
    : 'exists'
    ;

SQL92_RESERVED_FALSE
    : 'false'
    ;

SQL92_RESERVED_FETCH
    : 'fetch'
    ;

SQL92_RESERVED_FOR
    : 'for'
    ;

SQL92_RESERVED_FROM
    : 'from'
    ;

SQL92_RESERVED_GOTO
    : 'goto'
    ;

SQL92_RESERVED_GRANT
    : 'grant'
    ;

SQL92_RESERVED_GROUP
    : 'group'
    ;

SQL92_RESERVED_HAVING
    : 'having'
    ;

PLSQL_RESERVED_IDENTIFIED
    : 'identified'
    ;

PLSQL_RESERVED_IF
    : 'if'
    ;

SQL92_RESERVED_IN
    : 'in'
    ;

PLSQL_RESERVED_INDEX
    : 'index'
    ;

PLSQL_RESERVED_INDEXES
    : 'indexes'
    ;

SQL92_RESERVED_INSERT
    : 'insert'
    ;

SQL92_RESERVED_INTERSECT
    : 'intersect'
    ;

SQL92_RESERVED_INTO
    : 'into'
    ;

SQL92_RESERVED_IS
    : 'is'
    ;

SQL92_RESERVED_LIKE
    : 'like'
    ;

PLSQL_RESERVED_LOCK
    : 'lock'
    ;

PLSQL_RESERVED_MINUS
    : 'minus'
    ;

PLSQL_RESERVED_MODE
    : 'mode'
    ;

PLSQL_RESERVED_NOCOMPRESS
    : 'nocompress'
    ;

SQL92_RESERVED_NOT
    : 'not'
    ;

PLSQL_RESERVED_NOWAIT
    : 'nowait'
    ;

SQL92_RESERVED_NULL
    : 'null'
    ;

SQL92_RESERVED_OF
    : 'of'
    ;

SQL92_RESERVED_ON
    : 'on'
    ;

SQL92_RESERVED_OPTION
    : 'option'
    ;

SQL92_RESERVED_OR
    : 'or'
    ;

SQL92_RESERVED_ORDER
    : 'order'
    ;

SQL92_RESERVED_OVERLAPS
    : 'overlaps'
    ;

SQL92_RESERVED_PRIOR
    : 'prior'
    ;

SQL92_RESERVED_PROCEDURE
    : 'procedure'
    ;

SQL92_RESERVED_PUBLIC
    : 'public'
    ;

PLSQL_RESERVED_RESOURCE
    : 'resource'
    ;

SQL92_RESERVED_REVOKE
    : 'revoke'
    ;

SQL92_RESERVED_SELECT
    : 'select'
    ;

PLSQL_RESERVED_SHARE
    : 'share'
    ;

SQL92_RESERVED_SIZE
    : 'size'
    ;

// SQL92_RESERVED_SQL
//     : 'sql'
//     ;

PLSQL_RESERVED_START
    : 'start'
    ;

PLSQL_RESERVED_TABAUTH
    : 'tabauth'
    ;

SQL92_RESERVED_TABLE
    : 'table'
    ;

SQL92_RESERVED_THE
    : 'the'
    ;

SQL92_RESERVED_THEN
    : 'then'
    ;

SQL92_RESERVED_TO
    : 'to'
    ;

SQL92_RESERVED_TRUE
    : 'true'
    ;

SQL92_RESERVED_UNION
    : 'union'
    ;

SQL92_RESERVED_UNIQUE
    : 'unique'
    ;

SQL92_RESERVED_UPDATE
    : 'update'
    ;

SQL92_RESERVED_VALUES
    : 'values'
    ;

SQL92_RESERVED_VIEW
    : 'view'
    ;

PLSQL_RESERVED_VIEWS
    : 'views'
    ;

SQL92_RESERVED_WHEN
    : 'when'
    ;

SQL92_RESERVED_WHERE
    : 'where'
    ;

SQL92_RESERVED_WITH
    : 'with'
    ;

PLSQL_NON_RESERVED_USING
    : 'using'
    ;

PLSQL_NON_RESERVED_MODEL
    : 'model'
    /* TODO {
         // "model" is a keyword if and only if it is followed by ("main"|"partition"|"dimension")
         // otherwise it is a identifier(REGULAR_ID).
         // This wodoo implements something like context sensitive lexer.
         // Here we've matched the word "model". Then the Token is created and en-queued in tokenBuffer
         // We still remember the reference($m) onto this Token
         $m.setType(PLSQL_NON_RESERVED_MODEL);
         emit($m);
         advanceInput();

         $type = Token.INVALID_TOKEN_TYPE;
         int markModel = input.mark();

         // Now loop over next Tokens in the input and eventually set Token's type to REGULAR_ID

         // Subclassed version will return NULL unless EOF is reached.
         // nextToken either returns NULL => then the next token is put into the queue tokenBuffer
         // or it returns Token.EOF, then nothing is put into the queue
         Token t1 = super.nextToken();
         {    // This "if" handles the situation when the "model" is the last text in the input.
              if( t1 != null && t1.getType() == Token.EOF)
              {
                  $m.setType(REGULAR_ID);
              } else {
                  t1 = tokenBuffer.pollLast(); // "withdraw" the next token from the queue
                  while(true)
                  {
                     if(t1.getType() == EOF)   // is it EOF?
                     {
                         $m.setType(REGULAR_ID);
                         break;
                     }

                     if(t1.getChannel() == HIDDEN) // is it a white space? then advance to the next token
                     {
                         t1 = super.nextToken(); if( t1 == null) { t1 = tokenBuffer.pollLast(); };
                         continue;
                     }

                     if( t1.getType() != REGULAR_ID || // is something other than ("main"|"partition"|"dimension")
                        ( !t1.getText().equalsIgnoreCase("main") &&
                          !t1.getText().equalsIgnoreCase("partition") &&
                          !t1.getText().equalsIgnoreCase("dimension")
                       ))
                     {
                         $m.setType(REGULAR_ID);
                         break;
                     }

                     break; // we are in the model_clase do not rewrite anything
                  } // while true
              } // else if( t1 != null && t1.getType() == Token.EOF)
         }
         input.rewind(markModel);
    }*/
    ;

PLSQL_NON_RESERVED_ELSIF: 'elsif';
PLSQL_NON_RESERVED_PIVOT: 'pivot';
PLSQL_NON_RESERVED_UNPIVOT: 'unpivot';

REGULAR_ID
    : (SIMPLE_LETTER) (SIMPLE_LETTER | '$' | '_' | '#' | '0'..'9')*
    ;

ZV
    : '@!' -> channel(HIDDEN)
    ;
