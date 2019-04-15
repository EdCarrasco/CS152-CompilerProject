/*
    Flex specification that recognizes tokens in the MINI-L language.
    Prints out an error message and exits if any unrecognized character is
    encountered in the input.
    Prints the identified tokens to the screen, one token per line.
*/

%{
int currLine = 1, currPos = 1;
%}

LETTER [a-zA-Z]
DIGIT [0-9]
IDENTIFIER ({LETTER}({LETTER}|{DIGIT}|"_")*({LETTER}|{DIGIT}))|{LETTER}

%%

function	{ printf("FUNCTION\n"); currPos += yyleng; }
beginparams	{ printf("BEGIN_PARAMS\n"); currPos += yyleng; }
endparams	{ printf("END_PARAMS\n"); currPos += yyleng; }
beginlocals	{ printf("BEGIN_LOCALS\n"); currPos += yyleng; }
endlocals	{ printf("END_LOCALS\n"); currPos += yyleng; }
beginbody	{ printf("BEGIN_BODY\n"); currPos += yyleng; }
endbody		{ printf("END_BODY\n"); currPos += yyleng; }
integer		{ printf("INTEGER\n"); currPos += yyleng; }
array		{ printf("ARRAY\n"); currPos += yyleng; }
of			{ printf("OF\n"); currPos += yyleng; }
if			{ printf("IF\n"); currPos += yyleng; }
then		{ printf("THEN\n"); currPos += yyleng; }
endif		{ printf("ENDIF\n"); currPos += yyleng; }
else		{ printf("ELSE\n"); currPos += yyleng; }
while		{ printf("WHILE\n"); currPos += yyleng; }
do			{ printf("DO\n"); currPos += yyleng; }
beginloop	{ printf("BEGINLOOP\n"); currPos += yyleng; }
endloop		{ printf("ENDLOOP\n"); currPos += yyleng; }
continue	{ printf("CONTINUE\n"); currPos += yyleng; }
read		{ printf("READ\n"); currPos += yyleng; }
write		{ printf("WRITE\n"); currPos += yyleng; }
and			{ printf("AND\n"); currPos += yyleng; }
or			{ printf("OR\n"); currPos += yyleng; }
not			{ printf("NOT\n"); currPos += yyleng; }
true		{ printf("TRUE\n"); currPos += yyleng; }
false		{ printf("FALSE\n"); currPos += yyleng; }
return		{ printf("RETURN\n"); currPos += yyleng; }

"-"			{ printf("SUB\n"); currPos += yyleng; }
"+"			{ printf("ADD\n"); currPos += yyleng; }
"*"			{ printf("MULT\n"); currPos += yyleng; }
"/"			{ printf("DIV\n"); currPos += yyleng; }
"%"			{ printf("MOD\n"); currPos += yyleng; }

"=="		{ printf("EQ\n"); currPos += yyleng; }
"<>"		{ printf("NEQ\n"); currPos += yyleng; }
"<"			{ printf("LT\n"); currPos += yyleng; }
">"			{ printf("GT\n"); currPos += yyleng; }
"<="		{ printf("LTE\n"); currPos += yyleng; }
">="		{ printf("GTE\n"); currPos += yyleng; }

";"			{ printf("SEMICOLON\n"); currPos += yyleng; }
":"			{ printf("COLON\n"); currPos += yyleng; }
","			{ printf("COMMA\n"); currPos += yyleng; }
"("			{ printf("L_PAREN\n"); currPos += yyleng; }
")"			{ printf("R_PAREN\n"); currPos += yyleng; }
"["			{ printf("L_SQUARE_BRACKET\n"); currPos += yyleng; }
"]"			{ printf("R_SQUARE_BRACKET\n"); currPos += yyleng; }
":="		{ printf("ASSIGN\n"); currPos += yyleng; }

{IDENTIFIER}	{ printf("IDENT %s\n", yytext); currPos += yyleng; }
{DIGIT}+	{ printf("NUMBER %s\n", yytext); currPos += yyleng; }


[ \t]+		{/*ignore whitespace*/ currPos += yyleng;}
"\n"		{currLine++; currPos = 1;}
.			{printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%

int main(int argc, char ** argv) {
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
}
