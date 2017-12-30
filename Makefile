all: prog

progBison: bison.y
	bison -t -d bison.y

progLexer: lex.l
	flex lex.l

prog: progLexer progBison
	g++ -std=c++11 -o compiler lex.yy.c bison.tab.c

clean:
	rm -f compiler
