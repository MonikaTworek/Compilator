%{
%}

%x LATEX_COMMENT
%%

<INITIAL>\%.*\n ;

<INITIAL>"/begin{comment}"      { BEGIN(LATEX_COMMENT); }
<LATEX_COMMENT>"/end{comment}" 	{ BEGIN(INITIAL); }
<LATEX_COMMENT>.|\n   		{ }

%%

int main( int argc, char** argv )
{
	yylex();
}
