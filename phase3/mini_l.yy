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

    #include <iostream>
    #include <list>
    #include <string>
    #include <functional>
    #include <vector>
    #include <stdlib.h>
    #include <stdio.h>
    #include <tuple>
    #include <utility>

    #ifndef FOO
    #define FOO

    #define debug false

    void debug_print(std::string msg);
    void debug_print_char(std::string msg, std::string c);
    void debug_print_int(std::string msg, int i);

    std::string concat(std::vector<std::string> strings, std::string prefix, std::string delim);

    enum IdentType {

        INTEGER,
        ARRAY,
        FUNCTION
    };

    void populateKeywords();

    bool isKeyword(std::string str);

    bool isInSymbolTable(std::string name);

    bool checkIdType(std::string id, IdentType type);

    std::string generateTempReg();
    std::string generateTempLabel();

    struct ExprStruct {

    public:

        std::string original_name;
        std::string reg_name;
        std::vector < std::string > code;

        // ~ExprStruct() {}

        // ExprStruct& operator =(const ExprStruct& other) {

        //     this->reg_name = other.reg_name;
        //     this->code.insert(this->code.end(), other.code.begin(), other.code.end());
        // }

        friend std::ostream& operator <<(std::ostream& out, const ExprStruct& printMe) {

            for (std::string thisLineOfCode : printMe.code)
                out << thisLineOfCode << std::endl;

            return out;
        }
    };

    struct CtrlStatementStruct {

    public:

        std::string begin_label;
        std::string end_label;

        std::vector < std::string > code;
    };

    std::ostream& operator <<(std::ostream& out, const std::vector< ExprStruct > & printMe);

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
    #include <iostream>
    #include <sstream>
    #include <string>
    #include <map>
    #include <regex>
    #include <set>
    #include <algorithm>
    #include <climits>
    #include <unordered_set>

    //extern yy::location loc;

    yy::parser::symbol_type yylex();

    	/* define your symbol table, global variables,
    	 * list of keywords or any function you may need here */
    	
    enum IdentType;

    std::map< std::string, IdentType > symbol_table;
    std::unordered_set < std::string > keywords;            // reserved keywords

    bool errorOccurred = false;

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

%type  <ExprStruct> program function declaration mulop statement var expression term mult_expr
%type  <std::vector<ExprStruct>> statement_loop declaration_loop var_loop
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

prog_start:

    { populateKeywords(); } program {

        if (!errorOccurred)
            std::cout << $2;

        // Print error if there isn't a main function
        if (!checkIdType("main", IdentType::FUNCTION)) {

            yy::parser::error(@2, "No main function defined");
        }            
    }
;

program:

    /*epsilon*/ %empty {

        debug_print("program -> epsilon\n");
    }

    | program function {
        debug_print("program -> program function\n");

        $$.code.insert($$.code.end(), $1.code.begin(), $1.code.end());
        $$.code.insert($$.code.end(), $2.code.begin(), $2.code.end());
    }
;

function:   
    FUNCTION IDENTIFIER { 

        std::string function_name = $2;
        symbol_table.insert( std::pair<std::string, IdentType>(function_name, IdentType::FUNCTION) );

        if (isKeyword(function_name)) { 

            yy::parser::error(@2, "Function name \"" + function_name + "\" cannot be named the same as a keyword.");
        }

    } SEMICOLON
    BEGINPARAMS declaration_loop ENDPARAMS
    BEGINLOCALS declaration_loop ENDLOCALS
    BEGINBODY statement_loop ENDBODY {

        debug_print_char("function -> FUNCTION IDENTIFIER %s SEMICOLON ", $2);
        debug_print("BEGINPARAMS declaration_loop ENDPARAMS ");
        debug_print("BEGINLOCALS declaration_loop ENDLOCALS ");
        debug_print("BEGINBODY statement_loop ENDBODY\n");

        std::string function_name = $2;
        std::vector< ExprStruct > params = $6;
        std::vector< ExprStruct > locals = $9;
        std::vector< ExprStruct > body   = $12;

        //$$ = "func " + function_name + "\n";
        $$.code.push_back("func " + function_name);

        // params declaration loop
        // $$.code.insert($$.code.end(), params.begin(), params.end());
        for (ExprStruct this_expr_struct : params) {

            $$.code.insert($$.code.end(), this_expr_struct.code.begin(), this_expr_struct.code.end());
        }

        // locals declaration loop
        // $$.code.insert($$.code.end(), locals.begin(), locals.end());
        for (ExprStruct this_expr_struct : locals) {

            $$.code.insert($$.code.end(), this_expr_struct.code.begin(), this_expr_struct.code.end());
        }

        // body statement loop
        // $$.code.insert($$.code.end(), body.begin(), body.end());
        for (ExprStruct this_expr_struct : body) {

            $$.code.insert($$.code.end(), this_expr_struct.code.begin(), this_expr_struct.code.end());
        }

        $$.code.push_back("endfunc");
    }
;

declaration_loop:

    /*epsilon*/ %empty {

        debug_print("declaration_loop -> epsilon\n");
        // don't add anything to vector
    }

	| declaration_loop declaration SEMICOLON {

        debug_print("declaration_loop -> declaration_loop declaration SEMICOLON\n");

        $$.insert($$.end(), $1.begin(), $1.end());
        $$.push_back($2);
    }
;

statement_loop:

    statement SEMICOLON {

        debug_print("statement_loop -> statement SEMICOLON\n");
        $$.push_back($1);
    }

	| statement_loop statement SEMICOLON {

        debug_print("statement_loop -> statement_loop statement SEMICOLON\n");

        $$ = $1;
        $$.push_back($2);
    }
;

declaration:

    id_loop COLON INTEGER {

        debug_print("declaration -> id_loop COLON INTEGER\n");

        for (std::string thisId : $1) {

            // Ident id(thisName, INT_MAX, false);


            // Check if is repeat identifier
            if (isInSymbolTable(thisId)) {
                yy::parser::error(@1, "Multiple definitions of variable \"" + thisId + "\"");
            }
            else {
                symbol_table.insert( std::pair<std::string, IdentType>(thisId, IdentType::INTEGER));

                ExprStruct expr_struct;
                expr_struct.code.push_back(". " + thisId);
                expr_struct.reg_name = thisId;
             
                // $$.code.push_back(expr_struct);
                $$.code.insert($$.code.end(), expr_struct.code.begin(), expr_struct.code.end());
            }
        }


    }

	| id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {

        debug_print_int("declaration -> id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5);

        // NEW
        for (std::string thisId : $1) {

            // Check if is repeat identifier
            if (isInSymbolTable(thisId)) {
                yy::parser::error(@1, "Multiple definitions of variable \"" + thisId + "\"");
            }
            else {
                symbol_table.insert( std::pair<std::string, IdentType>(thisId, IdentType::INTEGER));

                // Generate code for declaring id's in a loop
                ExprStruct expr_struct;
                expr_struct.code.push_back(".[] " + thisId + ", " + std::to_string($5));
                expr_struct.reg_name = thisId;

                // $$.code.push_back(expr_struct);
                $$.code.insert($$.code.end(), expr_struct.code.begin(), expr_struct.code.end());
            }

            if ($5 <= 0) {

                yy::parser::error(@5, "Array \"" + thisId + "\" must be declared with size greater than zero");
            }
        }
    }
;

id_loop:

    IDENTIFIER {

        debug_print("id_loop -> IDENTIFIER");
        $$.push_back($1);
    }

    | id_loop COMMA IDENTIFIER {

        debug_print("id_loop -> id_loop COMMA IDENTIFIER");
               
        // Maintain id_loop's vector         
        for (std::string s : $1) {
            $$.push_back(s);
        }
                        
        $$.push_back($3);
    }
;

statement:

    var ASSIGN expression {
        debug_print("statement -> var ASSIGN expression\n"); 
        ExprStruct es;
        es.reg_name = generateTempReg();
        es.code.insert(es.code.end(), $3.code.begin(), $3.code.end());
        $$ = es;
    }

	| IF bool_expr THEN statement_loop ENDIF {

        debug_print("statement -> IF bool_expr THEN statement_loop ENDIF\n");

        // TODO
    
    }

	| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF {

        debug_print("statement -> IF bool_expr THEN statement_loop ELSE statement_loop ENDIF\n");
        
        // TODO

    }

	| bool_expr BEGINLOOP statement_loop ENDLOOP {

        debug_print("statement -> WHILE bool_expr BEGINLOOP statement_loop ENDLOOP\n");

        // TODO
    }

	| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr {

        debug_print("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr\n");
    }

	| READ var_loop {

        debug_print("statement -> READ var_loop\n");


        for (ExprStruct this_expr_struct : $2) {
            // thisCode.push_back(".< " + this_expr_struct.reg_name);


            //this_expr_struct.reg_name = 

            //$$.code.insert($$.code.end(), this_expr_struct.code.begin(), this_expr_struct.code.end());
            $$.code.push_back(".< " + this_expr_struct.original_name);
        }
    }

	| WRITE var_loop {

        debug_print("statement -> WRITE var_loop\n");
        // $$ = concat($2, ".> ", "\n");

        for (ExprStruct this_expr_struct : $2) {
            //$$.code.insert($$.code.end(), this_expr_struct.code.begin(), this_expr_struct.code.end());
            $$.code.push_back(".> " + this_expr_struct.original_name);
        }
    }

    | CONTINUE { debug_print("statement -> CONTINUE\n"); }
    | RETURN expression { debug_print("statement -> RETURN expression\n"); }
;

var_loop:

    var {

        debug_print("var_loop -> var\n");
        $$.push_back($1);

    }

	| var_loop COMMA var {

        debug_print("var_loop -> var_loop COMMA var\n");
        $$.insert($$.end(), $1.begin(), $1.end());
        $$.push_back($3);
    }
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

expression: 
    mult_expr { debug_print("expression -> mult_expr\n"); 
        $$ = $1;
    }
    | expression ADD mult_expr { debug_print("expression -> expression ADD mult_expr\n"); 

    }
    | expression SUB mult_expr { debug_print("expression -> expression SUB mult_expr\n"); }
;

mult_expr:
  
    term {
        debug_print("mult_expr -> term\n"); 
        $$ = $1;
    }

    | mult_expr mulop term { debug_print_char("mult_expr -> mult_expr %s term\n", $2.reg_name); 

    }
;

mulop: 	  MULT { $$.code.push_back("MULT"); }   //TEMP: TODO
	| DIV  { $$.code.push_back("DIV"); }
	| MOD { $$.code.push_back("MOD"); }
	;

term:

    var {
        debug_print("term -> var\n"); 
        $$ = $1;
    }
	| SUB var { debug_print("term -> SUB var\n"); }
	| NUMBER { debug_print_int("term -> NUMBER %d\n", $1); }
	| SUB NUMBER { debug_print_int("term -> SUB NUMBER %d\n", $2); }
	| L_PAREN expression R_PAREN { debug_print("term -> L_PAREN expression R_PAREN\n"); }
	| SUB L_PAREN expression R_PAREN { debug_print("term -> SUB L_PAREN expression R_PAREN\n"); }
	| IDENTIFIER L_PAREN R_PAREN { debug_print_char("term -> IDENTIFIER %s L_PAREN R_PAREN\n", $1); }
	| IDENTIFIER L_PAREN expression_loop R_PAREN {

        debug_print_char("term -> IDENTIFIER %s L_PAREN expression_loop R_PAREN\n", $1);
    
        // if (!containsFuncName($1)) {

        if (isInSymbolTable($1)) {

            yy::parser::error(@1, "Function \"" + $1 + "\" has not been declared in the current context");
        }
        if (!checkIdType($1, IdentType::FUNCTION)) {

            yy::parser::error(@1, "Attempted to call non-function \"" + $1 + "\"");
        }
    }
;

expression_loop:

    expression {
        debug_print("expression_loop -> expression");
    }

    | expression_loop COMMA expression {
        debug_print("expression_loop -> expression_loop COMMA expression");
    }
;
		
var:

    IDENTIFIER {

        debug_print_char("var -> IDENTIFIER %s\n", $1);

        if (!isInSymbolTable($1)) {

            yy::parser::error(@1, "Attempted to use undeclared variable \"" + $1 + "\".");
        }

        else if (checkIdType($1, IdentType::ARRAY)) {

            yy::parser::error(@1, "Attempted to use array variable \"" + $1 + "\" as a non-array variable.");
        }

        ExprStruct es;
        es.original_name = $1;
        es.reg_name = generateTempReg();
        es.code.push_back(". " + es.reg_name);
        $$ = es;
    }

	| IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET {

        debug_print_char("var -> IDENTIFIER %s L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n", $1);

        // $$ = ".[] " + $1 + ", " + $3;
        ExprStruct es;
        es.original_name = $1;
        es.code.push_back(".[] " + $1 + ", " + $3.reg_name);
        es.reg_name = generateTempReg();

        $$ = es;
    }
;

/*
inc_scope: %empty {

    scope++; 
    maxScope = (scope > maxScope ? scope : maxScope);
    }
;

dec_scope: %empty { scope--; } ;
*/

// going_into_loop: %empty { currentlyInLoop = true; }
// returning_from_loop: %empty { currentlyInLoop = false; }

%%

int main(int argc, char *argv[])
{
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
	std::cerr << "Error at location " << l << ": " << m << std::endl;
    errorOccurred = true;
}

void debug_print(std::string msg) {

    if (debug) printf("%s", msg.c_str());
}

void debug_print_char(std::string msg, std::string c) {

    if (debug) printf(msg.c_str(), c.c_str());
}

void debug_print_int(std::string msg, int i) {

    if (debug) printf(msg.c_str(), i);
}

std::string concat(std::vector<std::string> strings, std::string prefix, std::string delim) {

    std::string str = "";

    for (std::string this_str : strings)
        str += prefix + this_str + delim;

    return str;

}

// int Ident::static_id = 0;

bool isKeyword(std::string name) {
    return keywords.find(name) != keywords.end();
}

bool isInSymbolTable(std::string name) {

    return symbol_table.find(name) != symbol_table.end();
}

bool checkIdType(std::string id, IdentType type) {

    if (!isInSymbolTable(id)) return false;

    // If you're here, then id is in the symbol table
    return type == symbol_table.at(id);
}

std::ostream& operator <<(std::ostream& out, const std::vector< ExprStruct > & printMe) {

    for (ExprStruct thisExpr : printMe) {

        out << thisExpr << std::endl;
    }
}

std::string generateTempReg() {

    static int i = 0;

    return "__temp__" + std::to_string(i++);
}

std::string generateTempLabel() {

    static int i = 0;

    return "__label__" + std::to_string(i++);
}

void populateKeywords() {

    keywords.insert("function");
    keywords.insert("beginparams");
    keywords.insert("endparams");
    keywords.insert("beginlocals");
    keywords.insert("endlocals");
    keywords.insert("beginbody");
    keywords.insert("endbody");
    keywords.insert("integer");
    keywords.insert("array");
    keywords.insert("of");
    keywords.insert("if");
    keywords.insert("then");
    keywords.insert("endif");
    keywords.insert("else");
    keywords.insert("while");
    keywords.insert("do");
    keywords.insert("beginloop");
    keywords.insert("endloop");
    keywords.insert("continue");
    keywords.insert("read");
    keywords.insert("write");
    keywords.insert("and");
    keywords.insert("or");
    keywords.insert("not");
    keywords.insert("true");
    keywords.insert("false");
    keywords.insert("return");
}
