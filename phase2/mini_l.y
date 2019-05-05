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
%token <ival> NUMBER

%%

program:    /*epsilon*/ { printf("program -> epsilon\n"); }
    | program function { printf("program -> program function\n"); }
    ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGINPARAMS declaration_loop ENDPARAMS
            BEGINLOCALS declaration_loop ENDLOCALS
            BEGINBODY statement_loop ENDBODY
            { printf("function -> FUNCTION IDENTIFIER %s SEMICOLON ", $2);
            printf("BEGINPARAMS declaration_loop ENDPARAMS ");
            printf("BEGINLOCALS declaration_loop ENDLOCALS ");
            printf("BEGINBODY statement_loop ENDBODY\n"); }
            ;

declaration_loop: /*epsilon*/ { printf("declaration_loop -> epsilon\n"); }
    		| declaration_loop declaration SEMICOLON { printf("declaration_loop -> declaration_loop declaration SEMICOLON\n"); }
    		;

statement_loop: /*epsilon*/ { printf("statement_loop -> epsilon\n"); }
		| statement_loop statement SEMICOLON { printf("statement_loop -> statement_loop statement SEMICOLON\n"); }
		;

declaration:	  id_loop COLON INTEGER { printf("declaration -> id_loop COLON INTEGER\n"); }
		| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5); }
		;

id_loop: 	IDENTIFIER { printf("id_loop -> IDENTIFIER %s\n", $1); }
		| IDENTIFIER COMMA id_loop { printf("id_loop -> IDENTIFIER %s COMMA id_loop\n", $1); }
		;

statement:	  var ASSIGN expression { printf("statement -> var ASSIGN expression\n"); }
		| IF bool_expr THEN statement_loop ENDIF { printf("statement -> IF bool_expr THEN statement_loop ENDIF\n"); }
		| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF { printf("statement -> IF bool_expr THEN statement_loop ELSE statement_loop ENDIF\n"); }
		| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP { printf("statement -> WHILE bool_expr BEGINLOOP statement_loop ENDLOOP\n"); }
		| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr { printf("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr\n"); }
		| READ var_loop { printf("statement -> READ var_loop\n"); }
		| WRITE var_loop { printf("statement -> WRITE var_loop\n"); }
		| CONTINUE { printf("statement -> CONTINUE\n"); }
		| RETURN expression { printf("statement -> RETURN expression\n"); }
		;

var_loop:	  var { printf("var_loop -> var\n"); }
		| var COMMA var_loop { printf("var_loop -> var COMMA var_loop\n"); }
		;

bool_expr:	  relation_and_expr or_loop { printf("bool_expr -> relation_and_expr or_loop\n"); }
		;

or_loop:	  /*epsilon*/ { printf("or_loop -> epsilon\n"); }
		| OR relation_and_expr { printf("or_loop -> OR relation_and_expr\n"); }
		;

relation_and_expr:	  relation_expr and_loop { printf("relation_and_expr -> relation_expr and_loop\n"); }
			;

and_loop:	  /*epsilon*/ { printf("and_loop -> epsilon\n"); }
		| AND relation_expr and_loop { printf("and_loop -> AND relation_expr and_loop\n"); }
		;

relation_expr:	  expression comp expression { printf("relation_expr -> expression comp expression\n"); }
		| NOT expression comp expression { printf("relation_expr -> NOT expression comp expression\n"); }
		| TRUE { printf("relation_expr -> TRUE\n"); }
		| NOT TRUE { printf("relation_expr -> NOT TRUE\n"); }
		| FALSE { printf("relation_expr -> FALSE\n"); }
		| NOT FALSE { printf("relation_expr -> NOT FALSE\n"); }
		| L_PAREN bool_expr R_PAREN { printf("relation_expr -> L_PAREN bool_expr R_PAREN\n"); }
		;

comp:		  EQ { printf("comp -> EQ\n"); }
		| NEQ { printf("comp -> NEQ\n"); }
		| LT { printf("comp -> LT\n"); }
		| GT { printf("comp -> GT\n"); }
		| LTE { printf("comp -> LTE\n"); }
		| GTE { printf("comp -> GTE\n"); }
		;

expression:	  mult_expr mult_expr_loop { printf("expression -> mult_expr mult_expr_loop\n"); }
		;

mult_expr_loop:	  /*epsilon*/ { printf("mult_expr_loop -> epsilon\n"); }
		| SUB mult_expr mult_expr_loop { printf("mult_expr_loop -> SUB mult_expr mult_expr_loop\n"); }
		| ADD mult_expr mult_expr_loop { printf("mult_expr_loop -> ADD mult_expr mult_expr_loop\n"); }
		;

mult_expr:	  term term_loop { printf("mult_expr -> term term_loop\n"); }
		;

term_loop:	  /*epsilon*/ { printf("term_loop -> epsilon\n"); }
		| MULT term term_loop { printf("term_loop -> MULT term term_loop\n"); }
		| DIV term term_loop { printf("term_loop -> DIV term term_loop\n"); }
		| MOD term term_loop { printf("term_loop -> MOD term term_loop\n"); }
		;

term:		  var { printf("term -> var\n"); }
		| SUB var { printf("term -> SUB var\n"); }
		| NUMBER { printf("term -> NUMBER %d\n", $1); }
		| SUB NUMBER { printf("term -> SUB NUMBER %d\n", $2); }
		| L_PAREN expression R_PAREN { printf("term -> L_PAREN expression R_PAREN\n"); }
		| SUB L_PAREN expression R_PAREN { printf("term -> SUB L_PAREN expression R_PAREN\n"); }
		| IDENTIFIER L_PAREN R_PAREN { printf("term -> IDENTIFIER %s L_PAREN R_PAREN\n", $1); }
		| IDENTIFIER L_PAREN expression_loop R_PAREN { printf("term -> IDENTIFIER %s L_PAREN expression_loop R_PAREN\n", $1); }
		;

expression_loop:	  expression { printf("expression_loop -> expression\n"); }
			| expression COMMA expression_loop { printf("expression_loop -> expression COMMA expression_loop\n"); }
			;
		
var:		  IDENTIFIER { printf("var -> IDENTIFIER %s\n", $1); }
		| IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET { printf("var -> IDENTIFIER %s L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n", $1); }
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
