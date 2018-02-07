%{
#include <iostream>
#include "mod_math.h"
using namespace std;
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
 
void yyerror(const char *s);
%}
%token NUM ENDL CARRY
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'  
%%
input:
	  	%empty
	| 	input line	
	;
line:
	  	ENDL
	| 	exp ENDL 				{cout << "\nWynik: " << $1 << "\n";}
	| 	error ENDL
	;
exp:  
		exp '+' exp 			{cout << "+ "; $$ = sum_mod($1,$3);}
    |   exp '*' exp 			{cout << "* "; $$ = mul_mod($1,$3);}
    |   exp '-' exp 			{cout << "- "; $$ = dif_mod($1,$3);}
    |   exp '/' exp 			{if ($3 != 0) {cout << "/ "; $$ = div_mod($1,$3);} else {yyerror("jestes glupi"); YYERROR;}}
    |   '(' exp ')' 			{$$ = $2;}
    |   '-' exp %prec NEG 		{cout << "- "; $$ = neg_mod($2);}
    |   '-' NUM %prec NEG 		{cout << neg_mod($2) << " "; $$ = neg_mod($2);}
	| 	exp '^' exp        		{cout << "^ "; $$ = pow_mod($1, $3); }
    |   NUM     				{cout << mod($1) << " "; $$ = mod($1);}
    ;
%%
int main(){
    yyparse();
}
void yyerror (const char *msg) {
    cout << "\n" << msg << "\n";
}
