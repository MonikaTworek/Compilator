all:
	bison -d calc.y
	flex calc.l
	g++ -std=c++11 calc.tab.c lex.yy.c mod_math.cpp -lfl -o calc
