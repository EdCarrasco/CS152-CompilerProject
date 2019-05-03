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
    | function program
    ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGINPARAMS declaration_loop SEMICOLON ENDPARAMS
            BEGINLOCALS declaration_loop SEMICOLON ENDLOCALS
            BEGINBODY statement_loop SEMICOLON ENDBODY
            ;



declaration_loop: /*epsilon*/
    /* declaration_loop declaration SEMICOLON*/
    ;


statement_loop: /*epsilon*/
    /*| statement_loop statement SEMICOLON*/
    ;

/*declaration:;
statement:;
*/
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
