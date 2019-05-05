/*
BISON specification for MINI-L language

*/

%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *msg);
extern int currLine;
extern int currPos;
extern char* currStr;
FILE * yyin;
%}

%union{
    double dval;
    int ival;
    char* strval;
}

%error-verbose
%start program
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

program:    /*epsilon*/
    | program function
    ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGINPARAMS declaration_loop ENDPARAMS
            BEGINLOCALS declaration_loop ENDLOCALS
            BEGINBODY statement_loop ENDBODY
            ;



declaration_loop: /*epsilon*/
    		| declaration_loop declaration SEMICOLON
    		;


statement_loop: /*epsilon*/
		| statement_loop statement SEMICOLON
		;

declaration:	  id_loop COLON INTEGER
		| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		;

id_loop: 	IDENTIFIER
		| IDENTIFIER COMMA id_loop
		;

statement:	  var ASSIGN expression
		| IF bool_expr THEN statement_loop ENDIF
		| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF
		| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP
		| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr
		| READ var_loop
		| WRITE var_loop
		| CONTINUE
		| RETURN expression
		;

var_loop:	  var
		| var COMMA var_loop
		;

bool_expr:	  relation_and_expr or_loop
		;

or_loop:	  /**/
		| OR relation_and_expr
		;

relation_and_expr:	  relation_expr and_loop
			;

and_loop:	  /**/
		| AND relation_expr and_loop
		;

relation_expr:	  expression comp expression
		| NOT expression comp expression
		| TRUE
		| NOT TRUE
		| FALSE
		| NOT FALSE
		| L_PAREN bool_expr R_PAREN
		;

comp:		  EQ
		| NEQ
		| LT
		| GT
		| LTE
		| GTE
		;

expression:	  mult_expr mult_expr_loop
		;

mult_expr_loop:	  /**/
		| SUB mult_expr mult_expr_loop
		| ADD mult_expr mult_expr_loop
		;

mult_expr:	  term term_loop
		;

term_loop:	  /**/
		| MULT term term_loop
		| DIV term term_loop
		| MOD term term_loop
		;

term:		  var
		| SUB var
		| NUMBER
		| SUB NUMBER
		| L_PAREN expression R_PAREN
		| SUB L_PAREN expression R_PAREN
		| IDENTIFIER L_PAREN R_PAREN
		| IDENTIFIER L_PAREN expression_loop R_PAREN
		;

expression_loop:	  expression
			| expression COMMA expression_loop
			;
		
var:		  IDENTIFIER
		| IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET
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
