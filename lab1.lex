/*
    Flex specification that recognizes tokens in the calculator language.
    Prints out an error message and exits if any unrecognized character is
    encountered in the input.
    Prints the identified tokens to the screen, one token per line.
*/

%{
int currLine = 1, currPos = 1;
int numInt = 0, numOp = 0, numParen = 0, numEqual = 0;
%}

NUMBER           [0-9]+
SIGNEDNUMBER     ("+"|"-")?{NUMBER}
SCIENTIFICNUMBER {SIGNEDNUMBER}("."{NUMBER})?((E|e){SIGNEDNUMBER})?

%%

"+" {printf("PLUS\n"); currPos += yyleng; numOp++;}
"-" {printf("MINUS\n"); currPos += yyleng; numOp++;}
"*" {printf("MULT\n"); currPos += yyleng; numOp++;}
"/" {printf("DIV\n"); currPos += yyleng; numOp++;}
"(" {printf("L_PAREN\n"); currPos += yyleng; numParen++;}
")" {printf("R_PAREN\n"); currPos += yyleng; numParen++;}
"=" {printf("EQUAL\n"); currPos += yyleng; numEqual++;}

{SCIENTIFICNUMBER} {printf("NUMBER %s\n", yytext); currPos += yyleng; numInt++;}
[ \t]+ {/*ignore whitespace*/ currPos += yyleng;}
"\n" {currLine++; currPos = 1;}
. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

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
    printf("\nIntegers: %d \nOperators: %d \nParenthesis: %d \nEquals: %d \n", numInt, numOp, numParen, numEqual);
    return 0;
}
