/*
BISON specification for MINI-L language

*/

%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int currLine;
extern int currPos;
FILE * yyin;
%}

%union{
    double dval;
    int ival;
    char* strval;
}

%error-verbose
$start program
%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE 
%token WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token ADD SUB MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <strval> IDENTIFIER
%token <dval> NUMBER

%%

program :	  /* epsilon */
        	| function program
		;

function : 	  FUNCTION IDENTIFIER SEMICOLON BEGINPARAMS
		;

declaration : 	  declarationid COLON arrayof INTEGER
		;

arrayof : 	ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
		;

declarationid :   IDENTIFIER COMMA declarationid
		| IDENTIFIER
		;

statement : 	  var ASSIGN expresion
		| IF bool-exp THEN stmt else_stmt ENDIF
		| WHILE bool_expr BEGINLOOP stmt ENDLOOP
		| DO BEGINLOOP stmt ENDLOOP WHILE bool_expr
		| READ var_loop
		| WRITE var_loop
		| CONTINUE
		| RETURN expression
		;

stmt : 		  statement SEMICOLON
		| statement SEMICOLON stmt
		; 

else_stmt : 	  ELSE stmt
		;

var_loop : 	  var COMMA
		| var
		;

bool_expr : 	  relation_and_expr relandexpr_loop
		;

relandexpr_loop : or relation_and_expr relandexpr_loop
		| /* epsilon */
		;

relation_exp : 	  not_optional expression comp expression
		| not_optional TRUE
		| not_optional FALSE
		| not_optional L_PAREN bool_expr R_PAREN
		;

not_optional : 	  NOT
		| /* epsilon */
		; 

comp : 		  EQ
		| NEQ
		| LT
		| GT
		| LTE
		| GTE
		;

expression : 	  multiplicative_expr mulexpr_loop
		;

mulexpr_loop : 	  /* epsilon */
		| add_op multiplicative_expr mulexpr_loop

add_op : 	  ADD
		| SUB
		;

multiplicative_expr : 	  term term_loop
			;

term_loop : 	  mul_op term term_loop
		| /* epsilon */
		;

mul_op : 	  MULT
		| DIV
		| MOD
		;

term : 		  sign_optional var
		| sign_optional NUMBER
		| sign_optional L_PAREN expression R_PAREN
		| IDENTIFIER L_PAREN expression_loop R_PAREN
		;

expression_loop : /* epsilon */
		| expression
		| expression COMMA expression_loop
		;

var : 		  IDENTIFIER
		| IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET
		;


	
