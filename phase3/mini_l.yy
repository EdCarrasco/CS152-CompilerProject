%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
	/* you may need these deader files 
	 * add more header file if you need more
	 */


#include <list>
#include <string>
#include <functional>
#include <vector>

#ifndef FOO
#define FOO

#define debug false

void debug_print(std::string msg);
void debug_print_char(std::string msg, std::string c);
void debug_print_int(std::string msg, int i);


	/* define the sturctures using as types for non-terminals */

	/* end the structures for non-terminal types */

#endif // FOO

}



%code
{
#include "parser.tab.hh"

	/* you may need these deader files 
	 * add more header file if you need more
	 */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();

	/* define your symbol table, global variables,
	 * list of keywords or any function you may need here */
	
	/* end of your code */
}

%token END 0 "end of file";

	/* specify tokens, type of non-terminals and terminals here */
%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE 
%token WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token ADD SUB MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <std::string> IDENTIFIER
%token <int> NUMBER

%type  <std::string> program function declaration_loop statement_loop declaration mulop
%type  <std::vector<std::string>> id_loop


%right ASSIGN
%left  OR
%left  AND
%right NOT
%left  LT GT LTE GTE EQ NEQ
%left  ADD SUB
%left  MULT DIV MOD
%left  L_SQUARE_BRACKET R_SQUARE_BRACKET
%left  L_PAREN R_PAREN
	/* end of token specifications */

%%

%start prog_start;

	/* define your grammars here use the same grammars 
	 * you used in Phase 2 and modify their actions to generate codes
	 * assume that your grammars start with prog_start
	 */

prog_start: program {std::cout << $1;}
    ;

program:    /*epsilon*/ { debug_print("program -> epsilon\n"); $$ = "";}
    | program function { debug_print("program -> program function\n"); $$ = $1 + $2;}
    ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGINPARAMS declaration_loop ENDPARAMS
            BEGINLOCALS declaration_loop ENDLOCALS
            BEGINBODY statement_loop ENDBODY
            { debug_print_char("function -> FUNCTION IDENTIFIER %s SEMICOLON ", $2);
            debug_print("BEGINPARAMS declaration_loop ENDPARAMS ");
            debug_print("BEGINLOCALS declaration_loop ENDLOCALS ");
            debug_print("BEGINBODY statement_loop ENDBODY\n");
            
            $$ = "func " + $2 + "\n";

            $$ += $5 + "\n";
            $$ += $8 + "\n";
            $$ += $11 + "\n";

            $$ += "endfunc\n";}
            ;

declaration_loop: /*epsilon*/ { debug_print("declaration_loop -> epsilon\n"); $$ = ""; }
    		| declaration_loop declaration SEMICOLON {
                debug_print("declaration_loop -> declaration_loop declaration SEMICOLON\n");
                $$ = $1 + $2; }
    		;

statement_loop: statement SEMICOLON { debug_print("statement_loop -> statement SEMICOLON\n"); }
		| statement_loop statement SEMICOLON { debug_print("statement_loop -> statement_loop statement SEMICOLON\n"); }
		;

declaration:    id_loop COLON INTEGER { 
                    debug_print("declaration -> id_loop COLON INTEGER\n");
                    $$ = "";
                    for (std::string s : $1)
                        $$ += ". " + s + '\n';
                
                }
		| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { debug_print_int("declaration -> id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5); }
		;

id_loop:    IDENTIFIER {
                debug_print("id_loop -> IDENTIFIER");

                $$.push_back($1);
            }
    | id_loop COMMA IDENTIFIER {
                        debug_print("id_loop -> id_loop COMMA IDENTIFIER");
                        
                        for (std::string s : $1)
                            $$.push_back(s);
                        
                        $$.push_back($3);
                    }
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

int main(int argc, char *argv[])
{
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
	std::cerr << l << ": " << m << std::endl;
}

void debug_print(std::string msg) {

    if (debug) printf(msg.c_str());
}

void debug_print_char(std::string msg, std::string c) {

    if (debug) printf(msg.c_str(), c.c_str());
}

void debug_print_int(std::string msg, int i) {

    if (debug) printf(msg.c_str(), i);
}
