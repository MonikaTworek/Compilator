%{
#include<stack>
#include<string>
#include<iostream>
#include<cmath>
#include <sstream>

using namespace std;
stack<int> s;
string err = "";
%}

%option noyywrap c++
%%

[-+/*^%]		{	ECHO;
				if (s.size() > 1)
				{
					int b = s.top();
					s.pop();
					int a = s.top();
					s.pop();
					string op = YYText();
					if (op == "+") s.push(a+b);
					else if (op == "-") s.push(a-b);
					else if (op == "/") {
						if (b==0){
							err= "You are bad. You cannot divied by 0!";
						}
						else{
							s.push(a/b);
						}
					}
					else if (op == "*") s.push(a*b);
					else if (op == "^") s.push(pow(a,b));
					else if (op == "%") s.push(a%b);
				}
				else
				{
					s = stack<int>();
					err = "Not enough arguments.";
				}}
-?[0-9]*			{	ECHO;
				s.push(stoi(YYText()));}
\n			{ 	ECHO;
				if (err != "") cout << "Err: " << err << endl; 
				else if (s.size() == 1) {cout << "=" << s.top() << endl;}
				else if (s.size() == 0) cout << "Err: Not enough arguments.\n";
				else cout << "Err: Not enough operators.\n";
				s = stack<int>();
				err = "";}
[ \t]			{	ECHO;}
.			{	
				ECHO;
				ostringstream oss;
				oss << "Invalid symbol \"" << YYText() << "\"";
				err = oss.str();}

%%

int main( int /* argc */, char** /* argv */ )
{
	FlexLexer* lexer = new yyFlexLexer;
	while(lexer->yylex() != 0);
	return 0;
}
