%{
int char_in_line = 0;
int was_space = 0;
int words = 0;
int lines = 0;
%}

%%

\n 				{	if(char_in_line){
						printf("\n");
						lines++;
					}		
					char_in_line = 0;
					was_space = 0;
				}

[ \t] 				{	if(char_in_line){was_space=1;}
				}

[^\n ]		 		{
					char_in_line = 1;
					if(was_space){
						words++;
						was_space=0;
						printf(" %s", yytext);
					}
					else{printf("%s", yytext);}
				}

%%

int main()
{
	yylex();
	printf("\nlines: %d, words: %d\n", lines, words);
}
