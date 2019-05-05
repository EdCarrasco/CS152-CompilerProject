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

program :	  /* epsilon */ { printf("program -> epsilon\n"); }
        	| function program { printf("program -> function program\n"); }
		;

function : 	  FUNCTION IDENTIFIER SEMICOLON 
		  BEGINPARAMS declaration_loop ENDPARAMS 
		  BEGINLOCALS declaration_loop ENDLOCALS 
		  BEGINBODY statement_loop ENDBODY { printf("function -> FUNCTION IDENTIFIER %s SEMICOLON BEGINPARAMS declaration_loop ENDPARAMS BEGINLOCALS declaration_loop ENDLOCALS BEGINBODY statement_loop ENDBODY\n", $2); }
		;

declaration_loop : 	  /* epsilon */ { printf("declaration_loop -> epsilon\n"); }
			| declaration SEMICOLON declaration_loop { printf("declaration_loop -> declaration SEMICOLON declaration_loop\n"); }
			; 

declaration : 	  id_loop COLON INTEGER { printf("declaration -> id_loop COLON INTEGER\n"); }
		| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
		;

id_loop :   	  IDENTIFIER { printf("id_loop -> IDENTIFIER %s\n", $1); }
		| IDENTIFIER COMMA id_loop { printf("id_loop -> IDENTIFIER %s COMMA id_loop\n", $1); }
		;

statement : 	  var ASSIGN expression { printf("statement -> var ASSIGN expression\n"); }
		| IF bool_expr THEN statement_loop ENDIF { printf("statement -> IF bool_expr THEN statement_loop ENDIF\n"); }
		| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF { printf("statement -> IF bool_expr THEN statement_loop ELSE statement_loop ENDIF\n"); }
		| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP { printf("statement -> WHILE bool_expr BEGINLOOP statement_loop ENDLOOP\n"); }
		| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr { printf("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr\n"); }
		| READ var_loop { printf("statement -> READ var_loop\n"); }
		| WRITE var_loop { printf("statement -> WRITE var_loop\n"); }
		| CONTINUE { printf("statement -> CONTINUE\n"); }
		| RETURN expression { printf("statement -> RETURN expression\n"); }
		;

statement_loop :  statement SEMICOLON
		| statement SEMICOLON statement_loop
		;

var_loop : 	  var
		| var COMMA var_loop
		;

bool_expr : 	  relation_and_expr rel_and_expr_loop
		;

rel_and_expr_loop : 	  /* epsilon */
			| OR relation_and_expr rel_and_expr_loop
			;

relation_and_expr : 	  relation_expr relation_expr_loop
			;

relation_expr_loop : 	  /* epsilon */
			| AND relation_expr relation_expr_loop
			;

relation_expr :   not_optional expression comp expression
		| not_optional TRUE
		| not_optional FALSE
		| not_optional L_PAREN bool_expr R_PAREN
		;

not_optional : 	  /* epsilon */
		| NOT
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

term_loop : 	  /* epsilon */
		| mul_op term term_loop
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

sign_optional :   /* epsilon */
		| SUB
		;

expression_loop : /* epsilon */
		| expression
		| expression COMMA expression_loop
		;

var : 		  IDENTIFIER
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
    printf("** Line %d, position %d: %s \n", currLine, currPos, msg);
}	
