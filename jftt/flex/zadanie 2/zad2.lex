%{
int rzut = 0; 
int inline_comment = 0;
int big_comment = 0;
int doc_comment = 0;
int escaping=0;
int mode = 1;
%}

INLINE_COMMENT "//"
BIG_COMMENT "/*"
BIG_COMMENT_END "*/"
DOC_COMMENT "/**"
RZUT "\""
ESCAPING "\\\""
EXTENDED_INLINE "\\\n"

%%
{EXTENDED_INLINE} 	{
				if(inline_comment){inline_comment = 1;}
				else if(!inline_comment && rzut){
					rzut = 1;
					printf("\\\n");
				}
				else if(!inline_comment && !big_comment && !doc_comment){printf("\\\n");}
			}

{DOC_COMMENT} 		{
				if(mode == 1){
					if(!rzut){doc_comment=1;}
					else{printf("/**");}
				}
				else{printf("/**");}	
	
			}

{BIG_COMMENT} 		{
				if(!rzut){big_comment=1;}
				else{printf("/*");}
			}

{BIG_COMMENT_END} 	{
				if(!rzut){
					if(mode == 0 && !inline_comment && !big_comment && !doc_comment){printf("*/");}	
				big_comment=0;
				doc_comment=0;		
				}
					else{printf("*/");}
			}

{INLINE_COMMENT} 	{
				if(!rzut){inline_comment=1;}
				else{printf("//");}
			}

\n 			{
	
				if(!rzut){inline_comment = 0;}
				else{rzut = 0;}
				if(!inline_comment && !big_comment && !doc_comment){printf("\n");}
			}

{ESCAPING} 		{
				if(!inline_comment && !big_comment && !doc_comment){printf("\\\"");}
			}

{RZUT} 		{
				if(!inline_comment && !big_comment && !doc_comment){
					if(rzut){rzut = 0;}
					else{rzut = 1;}
					printf("\"");
				}
			}

. 			{
				if(!inline_comment && !big_comment && !doc_comment){printf("%s", yytext);}
			}

%%

int main()
{
	yylex();
}
