bison -v -d --file-prefix=y phase2/mini_l.y \
&& flex phase2/mini_l.lex \
&& mv -f y.* phase2/ \
&& mv -f lex.yy.c phase2/ \
&& gcc -o phase2/calc phase2/y.tab.c phase2/lex.yy.c -lfl \
&& ./phase2/calc phase2/testing.min

