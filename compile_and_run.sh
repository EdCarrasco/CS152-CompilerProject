bison -v -d --file-prefix=y phase2/calc.y \
&& flex phase2/mini_l.lex \
&& gcc -o phase2/calc phase2/y.tab.c phase2/lex.yy.c -lfl \
&& ./phase2/calc $1

