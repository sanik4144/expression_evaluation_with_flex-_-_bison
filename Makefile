calc: expr.tab.c lex.yy.c
	gcc -o calc expr.tab.c lex.yy.c -lfl -lm

expr.tab.c expr.tab.h: expr.y
	bison -d expr.y

lex.yy.c: expr.l expr.tab.h
	flex expr.l

clean:
	cmd /C del /Q calc.exe expr.tab.* lex.yy.c 2>nul
