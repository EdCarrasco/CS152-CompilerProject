bison -v -d --file-prefix=y calc.y \
&& flex mini_l.lex \
&& gcc -o calc y.tab.c lex.yy.c -lfl \
&& ./calc $1

