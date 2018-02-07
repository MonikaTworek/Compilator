%{
#include <iostream>
#include "calc.tab.h"
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "calc.tab.h"
%}
%x COMMENT
%%
<INITIAL>#		{BEGIN(COMMENT);}
<COMMENT>.|\\\n		;
<COMMENT>\n		{BEGIN(INITIAL);}
[0-9]+  		{yylval=atoi(yytext); return NUM;}
\\\n			;
\n			return ENDL;
.       		return *yytext;
%%
