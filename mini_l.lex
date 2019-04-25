/*
    Flex specification that recognizes tokens in the MINI-L language.
    Prints out an error message and exits if any unrecognized character is
    encountered in the input.
    Prints the identified tokens to the screen, one token per line.
*/

%{
#include "y.tab.h"
int currLine = 1, currPos = 1;
%}

LETTER      [a-zA-Z]
DIGIT       [0-9]
IDENTIFIER  ({LETTER}({LETTER}|{DIGIT}|"_")*({LETTER}|{DIGIT}))|{LETTER}
INVALIDID   ({DIGIT}+{IDENTIFIER})|({IDENTIFIER}"_"+)|({DIGIT}+{IDENTIFIER}?"_"+)
COMMENT     "#""#"+.*

%%

function	{ currPos += yyleng; return FUNCTION; }
beginparams	{ currPos += yyleng; return BEGINPARAMS; }
endparams	{ currPos += yyleng; return ENDPARAMS; }
beginlocals	{ currPos += yyleng; return BEGINLOCALS; }
endlocals	{ currPos += yyleng; return ENDLOCALS; }
beginbody	{ currPos += yyleng; return BEGINBODY; }
endbody		{ currPos += yyleng; return ENDBODY; }
integer		{ currPos += yyleng; return INTEGER; }
array		{ currPos += yyleng; return ARRAY; }
of		{ currPos += yyleng; return OF; }
if		{ currPos += yyleng; return IF; }
then		{ currPos += yyleng; return THEN; }
endif		{ currPos += yyleng; return ENDIF; }
else		{ currPos += yyleng; return ELSE; }
while		{ currPos += yyleng; return WHILE; }
do		{ currPos += yyleng; return DO; }
beginloop	{ currPos += yyleng; return BEGINLOOP; }
endloop		{ currPos += yyleng; return ENDLOOP; }
continue	{ currPos += yyleng; return CONTINUE; }
read		{ currPos += yyleng; return READ; }
write		{ currPos += yyleng; return WRITE; }
and		{ currPos += yyleng; return AND; }
or		{ currPos += yyleng; return OR; }
not		{ currPos += yyleng; return NOT; }
true		{ currPos += yyleng; return TRUE; }
false		{ currPos += yyleng; return FALSE; }
return		{ currPos += yyleng; return RETURN; }

"-"		{ currPos += yyleng; return SUB; }
"+"		{ currPos += yyleng; return ADD; }
"*"		{ currPos += yyleng; return MULT; }
"/"		{ currPos += yyleng; return DIV; }
"%"		{ currPos += yyleng; return MOD; }

"=="		{ currPos += yyleng; return EQ; }
"<>"		{ currPos += yyleng; return NEQ; }
"<"		{ currPos += yyleng; return LT; }
">"		{ currPos += yyleng; return GT; }
"<="		{ currPos += yyleng; return LTE; }
">="		{ currPos += yyleng; return GTE; }

";"		{ currPos += yyleng; return SEMICOLON; }
":"		{ currPos += yyleng; return COLON; }
","		{ currPos += yyleng; return COMMA; }
"("		{ currPos += yyleng; return L_PAREN; }
")"		{ currPos += yyleng; return R_PAREN; }
"["		{ currPos += yyleng; return L_SQUARE_BRACKET; }
"]"		{ currPos += yyleng; return R_SQUARE_BRACKET; }
":="		{ currPos += yyleng; return ASSIGN; }

{IDENTIFIER}	{ currPos += yyleng; return IDENTIFIER; }
{DIGIT}+	{ currPos += yyleng; return NUMBER; }
{INVALIDID} { printf("Error at line %d, column %d: invalid identifier \"%s\"\n", currLine, currPos, yytext); exit(0); }

{COMMENT}   {/*ignore comment*/ currLine++; currPos = 1; }
[ \t]+		{/*ignore whitespace*/ currPos += yyleng;}
"\n"		{currLine++; currPos = 1;}
.		{printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%

/*int main(int argc, char ** argv) {
    // The input text can be optionally read from an input file
    // (if one was specified on the command line)
    if (argc >= 2) {
        yyin = fopen(argv[1], "r"); // read file
        if (yyin == NULL) yyin = stdin; // if an error occurred, use standard input instead
    } else {
        yyin = stdin;
    }

    yylex(); // this is where the magic happens
    return 0;
}*/
