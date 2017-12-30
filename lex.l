%option noyywrap
%option yylineno
%{
#include <iostream>
#include <string>
#include <vector>

#include "bison.tab.h"


%}
%%
"VAR"		return t_VAR;
"BEGIN"		return t_BEGIN;
"END"		return t_END;

"WRITE"		return t_WRITE;
"READ"		return t_READ;

"IF"		return t_IF;
"THEN"		return t_THEN;
"ELSE"		return t_ELSE;
"ENDIF"		return t_ENDIF;

"WHILE"		return t_WHILE;
"DO"		return t_DO;
"ENDWHILE"	return t_ENDWHILE;

"FOR"		return t_FOR;
"FROM"		return t_FROM;
"TO"		return t_TO;
"DOWNTO"	return t_DOWNTO;
"ENDFOR"	return t_ENDFOR;


[_a-z]+		{yylval.pidentifier = new std::string(yytext); return t_pidentifier;}
[0-9]+ 		{yylval.number = atoll(yytext);	return t_num;}
"-"		return yytext[0];
[/*%\[\];><+=]	return yytext[0];
"<="		return t_LOWEROREQUAL;
">="		return t_GREATEROREQUAL;
":="		return t_ASSIGN;
"<>"		return t_NOTEQUAL;
[ \t]+ 		;
\([^)]*[)\n]	;
\n		;
.		return t_ERROR;
%%
