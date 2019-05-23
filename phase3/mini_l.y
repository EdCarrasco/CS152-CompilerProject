/*
BISON specification for MINI-L language

*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

void yyerror(const char *msg);
extern int currLine;
extern int currPos;
extern char* currStr;
FILE * yyin;
bool debug = false;

void debug_print(char* msg) {

    if (debug) printf(msg);
}

void debug_print_char(char* msg, char* c) {

    if (debug) printf(msg, c);
}

void debug_print_int(char* msg, int i) {

    if (debug) printf(msg, i);
}

%}

%union{
    double dval;
    int ival;
    char* strval;
}

%error-verbose
%start program
%type <strval> mulop

%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE 
%token WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token ADD SUB MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <strval> IDENTIFIER
%token <ival> NUMBER

%right ASSIGN
%left  OR
%left  AND
%right NOT
%left  LT GT LTE GTE EQ NEQ
%left  ADD SUB
%left  MULT DIV MOD
%left  L_SQUARE_BRACKET R_SQUARE_BRACKET
%left  L_PAREN R_PAREN

%%

program:    /*epsilon*/ { debug_print("program -> epsilon\n"); }
    | program function { debug_print("program -> program function\n"); }
    ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGINPARAMS declaration_loop ENDPARAMS
            BEGINLOCALS declaration_loop ENDLOCALS
            BEGINBODY statement_loop ENDBODY
            { debug_print_char("function -> FUNCTION IDENTIFIER %s SEMICOLON ", $2);
            debug_print("BEGINPARAMS declaration_loop ENDPARAMS ");
            debug_print("BEGINLOCALS declaration_loop ENDLOCALS ");
            debug_print("BEGINBODY statement_loop ENDBODY\n"); }
            ;

declaration_loop: /*epsilon*/ { debug_print("declaration_loop -> epsilon\n"); }
    		| declaration_loop declaration SEMICOLON { debug_print("declaration_loop -> declaration_loop declaration SEMICOLON\n"); }
    		;

statement_loop: statement SEMICOLON { debug_print("statement_loop -> statement SEMICOLON\n"); }
		| statement_loop statement SEMICOLON { debug_print("statement_loop -> statement_loop statement SEMICOLON\n"); }
		;

declaration:	 id_loop COLON INTEGER { debug_print("declaration -> id_loop COLON INTEGER\n"); }
		| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { debug_print_int("declaration -> id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5); }
		;

id_loop:    IDENTIFIER { debug_print("id_loop -> IDENTIFIER"); }
    | id_loop COMMA IDENTIFIER { debug_print("id_loop -> id_loop COMMA IDENTIFIER"); }
    ;

statement:	  var ASSIGN expression { debug_print("statement -> var ASSIGN expression\n"); }
		| IF bool_expr THEN statement_loop ENDIF { debug_print("statement -> IF bool_expr THEN statement_loop ENDIF\n"); }
		| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF { debug_print("statement -> IF bool_expr THEN statement_loop ELSE statement_loop ENDIF\n"); }
		| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP { debug_print("statement -> WHILE bool_expr BEGINLOOP statement_loop ENDLOOP\n"); }
		| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr { debug_print("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr\n"); }
		| READ var_loop { debug_print("statement -> READ var_loop\n"); }
		| WRITE var_loop { debug_print("statement -> WRITE var_loop\n"); }
		| CONTINUE { debug_print("statement -> CONTINUE\n"); }
		| RETURN expression { debug_print("statement -> RETURN expression\n"); }
		;

var_loop:	  var { debug_print("var_loop -> var\n"); }
		| var_loop COMMA var { debug_print("var_loop -> var_loop COMMA var\n"); }
		;

bool_expr:	  relation_and_expr { debug_print("bool_expr -> relation_and_expr\n"); }
        | bool_expr OR relation_and_expr { debug_print("bool_expr -> bool_expr OR relation_and_expr\n"); }
        ;

relation_and_expr:	  relation_expr { debug_print("relation_and_expr -> relation_expr\n"); }
        | relation_and_expr AND relation_expr { debug_print("relation_and_expr -> relation_and_expr AND relation_expr\n"); }
        ;

relation_expr:	  expression comp expression { debug_print("relation_expr -> expression comp expression\n"); }
		| NOT expression comp expression { debug_print("relation_expr -> NOT expression comp expression\n"); }
		| TRUE { debug_print("relation_expr -> TRUE\n"); }
		| NOT TRUE { debug_print("relation_expr -> NOT TRUE\n"); }
		| FALSE { debug_print("relation_expr -> FALSE\n"); }
		| NOT FALSE { debug_print("relation_expr -> NOT FALSE\n"); }
		| L_PAREN bool_expr R_PAREN { debug_print("relation_expr -> L_PAREN bool_expr R_PAREN\n"); }
		;

comp:		  EQ { debug_print("comp -> EQ\n"); }
		| NEQ { debug_print("comp -> NEQ\n"); }
		| LT { debug_print("comp -> LT\n"); }
		| GT { debug_print("comp -> GT\n"); }
		| LTE { debug_print("comp -> LTE\n"); }
		| GTE { debug_print("comp -> GTE\n"); }
		;

expression: mult_expr { debug_print("expression -> mult_expr\n"); }
        | expression ADD mult_expr { debug_print("expression -> expression ADD mult_expr\n"); }
        | expression SUB mult_expr { debug_print("expression -> expression SUB mult_expr\n"); }
        ;

mult_expr:	  term  { debug_print("mult_expr -> term\n"); }
        | mult_expr mulop term { debug_print_char("mult_expr -> mult_expr %s term\n", $2); }
        ;

mulop: 	  MULT { $$ = "MULT"; }
	| DIV  { $$ = "DIV"; }
	| MOD { $$ = "MOD"; }
	;

term:		  var { debug_print("term -> var\n"); }
		| SUB var { debug_print("term -> SUB var\n"); }
		| NUMBER { debug_print_int("term -> NUMBER %d\n", $1); }
		| SUB NUMBER { debug_print_int("term -> SUB NUMBER %d\n", $2); }
		| L_PAREN expression R_PAREN { debug_print("term -> L_PAREN expression R_PAREN\n"); }
		| SUB L_PAREN expression R_PAREN { debug_print("term -> SUB L_PAREN expression R_PAREN\n"); }
		| IDENTIFIER L_PAREN R_PAREN { debug_print_char("term -> IDENTIFIER %s L_PAREN R_PAREN\n", $1); }
		| IDENTIFIER L_PAREN expression_loop R_PAREN { debug_print_char("term -> IDENTIFIER %s L_PAREN expression_loop R_PAREN\n", $1); }
		;

expression_loop:    expression { debug_print("expression_loop -> expression"); }
    | expression_loop COMMA expression { debug_print("expression_loop -> expression_loop COMMA expression"); }
    ;
		
var:		  IDENTIFIER { debug_print_char("var -> IDENTIFIER %s\n", $1); }
		| IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET { debug_print_char("var -> IDENTIFIER %s L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n", $1); }
		;

%%



int main(int argc, char ** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            printf("syntax: %s filename", argv[0]);
        }
    }
    yyparse(); // more magical stuff
    return 0;
}

void yyerror(const char *msg) {
    printf("** ----- Line %d, position %d: %s \n", currLine, currPos, msg);
}	
