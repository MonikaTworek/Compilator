%{
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <stdlib.h>
#include <map>

int yylex();
int yylineo; 
void yyerror(const char *e);

using namespace std;

long long index = 10;
long long label = 100;

struct lolStructTmp {
	vector<string> *commands;
	long long index;
};
typedef struct lolStructTmp pidentifierStruct;
// index -> label
typedef struct lolStructTmp conditionStruct;

struct varStructTmp {
	long long address;
	long long size;
	bool isTab;
};
typedef struct varStructTmp varStruct;
map<string, varStruct> mem;

vector<string> *genVal(long long val);
vector<string> *read(pidentifierStruct *pidStruct);
vector<string> *write(pidentifierStruct *pidStruct);
vector<string> *Add(vector<string> *a, vector<string> *b);
vector<string> *Sub(vector<string> *a, vector<string> *b);
vector<string> *Mul(vector<string> *a, vector<string> *b);
vector<string> *Div(vector<string> *a, vector<string> *b);
vector<string> *Mod(vector<string> *a, vector<string> *b);
vector<string> *genIf(conditionStruct *cond, vector<string> *cmds);
vector<string> *genIfElse(conditionStruct *cond, vector<string> *cmds1, vector<string> *cmds2);
vector<string> *genWhile(conditionStruct *cond, vector<string> *cmds, long long localIndex);
vector<string> *genFor(string *name, vector<string> *from, vector<string> *to, vector<string> *cmds, long long localLabel, long long localIndex);
vector<string> *genForDownto(string *name, vector<string> *from, vector<string> *to, vector<string> *cmds, long long localLabel, long long localIndex);
vector<string> *valToReg(pidentifierStruct *a, vector<string> *cmds);
conditionStruct *equal(vector<string> *a, vector<string> *b);
conditionStruct *not_equal(vector<string> *a, vector<string> *b);
conditionStruct *lower(vector<string> *a, vector<string> *b);
conditionStruct *lower_equal(vector<string> *a, vector<string> *b);
conditionStruct *Greater(vector<string> *a, vector<string> *b);
conditionStruct *Greater_equal(vector<string> *a, vector<string> *b);

void printProgram(vector<string> *vec);
void varDef(string name, bool isTab, long long size);
void varDel(string name);

%}
%union{
	std::string *pidentifier;
	std::vector<std::string> *vec;
	void *pidStruct; // pointer to pidentifierStruct
	void *condStruct; // pointer to pidentifierStruct
	long long number;
}

%type <vec> program
%type <vec> commands
%type <vec> command
%type <condStruct> condition
%type <vec> value
%type <vec> expression
%type <pidStruct> identifier
%token <pidentifier> t_pidentifier
%token <number> t_num

%token t_VAR
%token t_BEGIN
%token t_END
%token t_READ
%token t_WRITE
%token t_IF
%token t_THEN
%token t_ELSE
%token t_ENDIF
%token t_FOR
%token t_FROM
%token t_TO
%token t_DOWNTO
%token t_ENDFOR
%token t_WHILE
%token t_DO
%token t_ENDWHILE
%token t_ASSIGN
%token t_EQUAL
%token t_NOTEQUAL
%token t_GREATER
%token t_LOWER
%token t_GREATEROREQUAL
%token t_LOWEROREQUAL
%token t_ENDLINE
%token t_ERROR

%%


program : t_VAR vdeclarations t_BEGIN commands t_END { $4->push_back("HALT"); printProgram($4); }
vdeclarations : vdeclarations t_pidentifier { varDef(*$2, false, 1); }
| vdeclarations t_pidentifier '[' t_num ']' { varDef(*$2, true, $4); }
|;
commands : commands command {
	    					$$ = $1;
						$$->insert($$->end(), $2->begin(), $2->end());
					}
|command { $$ = $1; };
command : identifier t_ASSIGN expression';' { $$ = valToReg((pidentifierStruct*)$1, $3); }
| t_IF condition t_THEN
			commands t_ELSE commands t_ENDIF { $$ = genIfElse((conditionStruct*)$2, $4, $6); }
| t_IF condition t_THEN
			commands t_ENDIF { $$ = genIf((conditionStruct*)$2, $4); }
| t_WHILE condition { $<number>$ = label; label += 2; } t_DO commands t_ENDWHILE { $$ = genWhile((conditionStruct*)$2, $5, $<number>3); }
| t_FOR t_pidentifier t_FROM value t_TO value t_DO
		{ $<number>$ = label; label+=2;} { varDef(*$2, false, 1); $<number>$ = index; index+=2; } commands t_ENDFOR
		{ index-=2; $$ = genFor($2, $4, $6, $10, $<number>8, $<number>9); varDel(*$2); }
| t_FOR t_pidentifier t_FROM value t_DOWNTO value t_DO
		{ $<number>$ = label; label+=2;} { varDef(*$2, false, 1); $<number>$ = index; index+=2; } commands t_ENDFOR
		{ index-=2; $$ = genForDownto($2, $4, $6, $10, $<number>8, $<number>9); varDel(*$2);  }
| t_READ identifier';' { $$ = read((pidentifierStruct*)$2); }
| t_WRITE value';' {
					$$ = $2;
					$$->push_back("PUT");
				};
expression : value { $$ = $1; }
| value '+' value { $$ = Add($1, $3); }
| value '-' value { $$ = Sub($1, $3); }
| value '*' value { $$ = Mul($1, $3); }
| value '/' value {$$ = Div($1, $3);}
condition : value '=' value	{ $$ = equal($1, $3); }
| value t_NOTEQUAL value { $$ = not_equal($1, $3); }
| value '<' value { $$ = lower($1, $3); }
| value '>' value { $$ = Greater($1, $3); }
| value t_LOWEROREQUAL value { $$ = lower_equal($1, $3); }
| value t_GREATEROREQUAL value { $$ = Greater_equal($1, $3); };
value : t_num { $$ = genVal($1); }
| identifier {
			vector<string> *commands = new vector<string>();
			auto pidStruct = (pidentifierStruct*)$1;
			if (pidStruct->index < 0) {
				commands->insert(commands->begin(), pidStruct->commands->begin(), pidStruct->commands->end());
				commands->push_back("STORE " + to_string(index));
				commands->push_back("LOADI " + to_string(index));
			} else {
				commands->push_back("LOAD " + to_string(pidStruct->index));
			}
			$$ = commands;
		};
identifier : t_pidentifier {
						pidentifierStruct *ret = new pidentifierStruct();
						ret->index = mem[*$1].address;
		 				$$ = ret;
					}
| t_pidentifier '[' t_num ']' {
						pidentifierStruct *ret = new pidentifierStruct();
						ret->index = mem[*$1].address + $3;
		 				$$ = ret;
					}
| t_pidentifier '[' t_pidentifier ']' {
						pidentifierStruct *ret = new pidentifierStruct();
						ret->index = -1;
						ret->commands = genVal(mem[*$1].address);
						ret->commands->push_back("ADD " + to_string(mem[*$3].address));
		 				$$ = ret;
					};

%%

void printProgram(vector<string> *vec) {
	map<string,int> labels;

	for(int i = 0; i < vec->size(); i++) {
		if ((*vec)[i].substr(0, 5) == "LABEL") {
			labels[(*vec)[i].substr(5)] = i;
		}
	}
	for(int i = 0; i < vec->size(); i++) {
		if ((*vec)[i].substr(0, 4) == "JUMP") {
			(*vec)[i] = "JUMP " + to_string(labels[(*vec)[i].substr(5)]);
		}
		if ((*vec)[i].substr(0, 5) == "JZERO") {
			(*vec)[i] = "JZERO " + to_string(labels[(*vec)[i].substr(6)]);
		}
	}
	for(int i = 0; i < vec->size(); i++) {
		if ((*vec)[i].substr(0, 5) == "LABEL") {
			(*vec)[i] = "JUMP " + to_string(i + 1);
		}
	}

	for(int i = 0; i < vec->size(); i++) {
		cout << (*vec)[i] << endl;
	}
}

void varDef(string name, bool isTab, long long size) {
	varStruct var = {index, size, isTab};
	mem[name] = var;
	index += size;
}

void varDel(string name) {
	index -= mem[name].size;
	mem.erase(name);
}

vector<string> *read(pidentifierStruct *pidStruct) {
	vector<string> *commands = new vector<string>();
	if (pidStruct->index < 0) {
		commands->insert(commands->begin(), pidStruct->commands->begin(), pidStruct->commands->end());
		commands->push_back("STORE " + to_string(index));
		commands->push_back("GET");
		commands->push_back("STOREI " + to_string(index));
	} else {
		commands->push_back("GET");
		commands->push_back("STORE " + to_string(pidStruct->index));
	}
	return commands;
}

vector<string> *write(vector<string> *tmp) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->begin(), tmp->begin(), tmp->end());
	commands->push_back("PUT");
	return commands;
}

vector<string> *genVal(long long val) {
	vector<string> *commands = new vector<string>();
	/* commands->push_back("1 genVal"); */
	vector<int> tmp;
	while(val) {
		tmp.push_back(val%2);
		val /=2;
	}
	commands->push_back("ZERO");
	for(int i = tmp.size() -1; i >= 0; i--) {
		if(tmp[i])
			commands->push_back("INC");
		if(i)
			commands->push_back("SHL");
	}
	/* commands->push_back("2 genVal"); */
	return commands;
}
vector<string> *Add(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 1");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("ADD 1");
	return commands;
}
vector<string> *Sub(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 1");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("SUB 1");
	return commands;
}
vector<string> *Mul(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("STORE 8");
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 7");
	commands->push_back("ZERO");
	commands->push_back("STORE 6");


	commands->push_back("LABEL" + to_string(label));

	commands->push_back("LOAD 7");
	
	commands->push_back("JZERO " + to_string(label + 1));
	commands->push_back("DEC");
	commands->push_back("STORE 7");
	commands->push_back("LOAD 6");
	commands->push_back("ADD 8");
	commands->push_back("STORE 6");
	commands->push_back("JUMP " + to_string(label));
	commands->push_back("LABEL" + to_string(label + 1));
	commands->push_back("LOAD 6");

	label += 2;
	return commands;
}
vector<string> *Div(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->push_back("ZERO");
	commands->push_back("STORE 9");
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 7");
	commands->push_back("JZERO " + to_string(label + 5));

	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("STORE 8");
	commands->push_back("ZERO");
	commands->push_back("STORE 9");
	commands->push_back("INC");
	commands->push_back("STORE 6");
	commands->push_back("LABEL" + to_string(label)); // begin while
	commands->push_back("LOAD 8");
	commands->push_back("INC");
	commands->push_back("SUB 7");
	commands->push_back("JZERO " + to_string(label + 1));
	commands->push_back("LOAD 6");
	commands->push_back("INC");
	commands->push_back("STORE 6");
	commands->push_back("LOAD 7");
	commands->push_back("SHL");
	commands->push_back("STORE 7");


	commands->push_back("JUMP " + to_string(label));
	commands->push_back("LABEL" + to_string(label + 1));
	commands->push_back("LOAD 7");
	commands->push_back("SHR");
	commands->push_back("STORE 7");
	commands->push_back("LABEL" + to_string(label + 2)); // begin for
	commands->push_back("LOAD 6");
	commands->push_back("DEC");
	commands->push_back("JZERO " + to_string(label + 5)); // end for condition
	commands->push_back("STORE 6");
	commands->push_back("LOAD 8"); // begin if
	commands->push_back("INC");
	commands->push_back("SUB 7");
	commands->push_back("JZERO " + to_string(label + 3)); // end if condition
	commands->push_back("DEC");
	commands->push_back("STORE 8");
	commands->push_back("LOAD 9");
	commands->push_back("SHL");
	commands->push_back("INC");
	commands->push_back("STORE 9");
	commands->push_back("JUMP " + to_string(label + 4));
	commands->push_back("LABEL" + to_string(label + 3));
	commands->push_back("LOAD 9");
	commands->push_back("SHL");
	commands->push_back("STORE 9");
	commands->push_back("LABEL" + to_string(label + 4));
	commands->push_back("LOAD 7");
	commands->push_back("SHR");
	commands->push_back("STORE 7");
	commands->push_back("JUMP " + to_string(label + 2));
	commands->push_back("LABEL" + to_string(label + 5));
	commands->push_back("LOAD 9");
	label += 6;
	
	return commands;
}
vector<string> *Mod(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();

	commands->push_back("ZERO");
	commands->push_back("STORE 8");
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 7");
	commands->push_back("JZERO " + to_string(label + 5));
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("STORE 8");
	commands->push_back("ZERO");
	commands->push_back("STORE 9");
	commands->push_back("INC");
	commands->push_back("STORE 6");
	commands->push_back("LABEL" + to_string(label));
	commands->push_back("LOAD 8");
	commands->push_back("INC");
	commands->push_back("SUB 7");
	commands->push_back("JZERO " + to_string(label + 1));
	commands->push_back("LOAD 6");
	commands->push_back("INC");
	commands->push_back("STORE 6");
	commands->push_back("LOAD 7");
	commands->push_back("SHL");
	commands->push_back("STORE 7");


	commands->push_back("JUMP " + to_string(label));
	commands->push_back("LABEL" + to_string(label + 1));
	commands->push_back("LOAD 7");
	commands->push_back("SHR");
	commands->push_back("STORE 7");
	commands->push_back("LABEL" + to_string(label + 2)); // begin for
	commands->push_back("LOAD 6");
	commands->push_back("DEC");
	commands->push_back("JZERO " + to_string(label + 5)); // end for condition
	commands->push_back("STORE 6");
	commands->push_back("LOAD 8"); // begin if
	commands->push_back("INC");
	commands->push_back("SUB 7");
	commands->push_back("JZERO " + to_string(label + 3)); // end if condition
	commands->push_back("DEC");
	commands->push_back("STORE 8");
	commands->push_back("LOAD 9");
	commands->push_back("SHL");
	commands->push_back("INC");
	commands->push_back("STORE 9");
	commands->push_back("JUMP " + to_string(label + 4));
	commands->push_back("LABEL" + to_string(label + 3));
	commands->push_back("LOAD 9");
	commands->push_back("SHL");
	commands->push_back("STORE 9");
	commands->push_back("LABEL" + to_string(label + 4));
	commands->push_back("LOAD 7");
	commands->push_back("SHR");
	commands->push_back("STORE 7");
	commands->push_back("JUMP " + to_string(label + 2));
	commands->push_back("LABEL" + to_string(label + 5));
	commands->push_back("LOAD 8");
	label += 6;
	
	return commands;
	
}

vector<string> *valToReg(pidentifierStruct *var, vector<string> *cmds) {
	vector<string> *commands = new vector<string>();
	/* commands->push_back("1 valToReg"); */
	if (var->index < 0) {
		commands->insert(commands->begin(), var->commands->begin(), var->commands->end());
		commands->push_back("STORE 5");
	}
	commands->insert(commands->end(), cmds->begin(), cmds->end());
	if (var->index < 0) {
		commands->push_back("STOREI 5");
	} else {
		commands->push_back("STORE " + to_string(var->index));
	}
	/* commands->push_back("2 valToReg"); */
	return commands;
}

vector<string> *genIf(conditionStruct *cond, vector<string> *cmds) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), cond->commands->begin(), cond->commands->end());
	commands->insert(commands->end(), cmds->begin(), cmds->end());
	commands->push_back("LABEL" + to_string(cond->index));
	return commands;
}

vector<string> *genIfElse(conditionStruct *cond, vector<string> *cmds1, vector<string> *cmds2) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), cond->commands->begin(), cond->commands->end());
	commands->insert(commands->end(), cmds1->begin(), cmds1->end());
	commands->push_back("JUMP " + to_string(label + 1));
	commands->push_back("LABEL" + to_string(cond->index));
	commands->insert(commands->end(), cmds2->begin(), cmds2->end());
	commands->push_back("LABEL" + to_string(label + 1));
	label += 2;
	return commands;
}

vector<string> *genFor(string *name, vector<string> *from, vector<string> *to, vector<string> *cmds, long long localLabel, long long localIndex) {
	vector<string> *commands = new vector<string>();
	long long iterator = mem[*name].address;
	commands->insert(commands->end(), to->begin(), to->end());
	commands->push_back("STORE " + to_string(localIndex));
	commands->insert(commands->end(), from->begin(), from->end());
	commands->push_back("STORE " + to_string(iterator));
	commands->push_back("LABEL" + to_string(localLabel + 1)); // begin
	commands->push_back("LOAD " + to_string(localIndex));
	commands->push_back("INC");
	commands->push_back("SUB " + to_string(iterator));
	commands->push_back("JZERO " + to_string(localLabel));
	commands->insert(commands->end(), cmds->begin(), cmds->end());
	commands->push_back("LOAD " + to_string(iterator));
	commands->push_back("INC");
	commands->push_back("STORE " + to_string(iterator));
	commands->push_back("JUMP " + to_string(localLabel + 1));
	commands->push_back("LABEL" + to_string(localLabel)); // end
	return commands;
}

vector<string> *genForDownto(string *name, vector<string> *from, vector<string> *to, vector<string> *cmds, long long localLabel, long long localIndex) {
	vector<string> *commands = new vector<string>();
	long long iterator = mem[*name].address;
	long long iteratorReal = localIndex + 1;
	long long toCopy = localIndex;
	commands->insert(commands->end(), to->begin(), to->end());
	commands->push_back("INC");
	commands->push_back("STORE " + to_string(toCopy));
	commands->insert(commands->end(), from->begin(), from->end());
	commands->push_back("STORE " + to_string(iterator));
	commands->push_back("INC");
	commands->push_back("STORE " + to_string(iteratorReal));

	commands->push_back("LABEL" + to_string(localLabel + 1)); // begin
	commands->push_back("LOAD " + to_string(iteratorReal));
	commands->push_back("INC");
	commands->push_back("SUB " + to_string(toCopy));
	commands->push_back("JZERO " + to_string(localLabel));
	commands->insert(commands->end(), cmds->begin(), cmds->end());
	commands->push_back("LOAD " + to_string(iteratorReal));
	commands->push_back("DEC");
	commands->push_back("STORE " + to_string(iteratorReal));
	commands->push_back("DEC");
	commands->push_back("STORE " + to_string(iterator));
	commands->push_back("JUMP " + to_string(localLabel + 1));
	commands->push_back("LABEL" + to_string(localLabel)); // end
	return commands;
}

vector<string> *genWhile(conditionStruct *cond, vector<string> *cmds, long long localIndex) {
	vector<string> *commands = new vector<string>();
	commands->push_back("LABEL" + to_string(localIndex + 1));
	commands->insert(commands->end(), cond->commands->begin(), cond->commands->end());
	commands->insert(commands->end(), cmds->begin(), cmds->end());
	commands->push_back("JUMP " + to_string(localIndex + 1));
	commands->push_back("LABEL" + to_string(cond->index));
	return commands;
}

conditionStruct *equal(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->begin(), b->begin(), b->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("INC");
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label));
	commands->push_back("DEC");
	commands->push_back("JZERO " + to_string(label+1));
	commands->push_back("JUMP " + to_string(label));
	commands->push_back("LABEL" + to_string(label+1));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label += 2;
	return ret;
}
conditionStruct *not_equal(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("INC");
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label + 1));
	commands->push_back("DEC");
	commands->push_back("JZERO " + to_string(label));
	commands->push_back("LABEL" + to_string(label + 1));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label += 2;
	return ret;
}
conditionStruct *lower(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label++;
	return ret;
}
conditionStruct *lower_equal(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("INC");
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label++;
	return ret;
}

conditionStruct *Greater(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label++;
	return ret;
}

conditionStruct *Greater_equal(vector<string> *a, vector<string> *b) {
	vector<string> *commands = new vector<string>();
	commands->insert(commands->end(), b->begin(), b->end());
	commands->push_back("STORE 0");
	commands->insert(commands->end(), a->begin(), a->end());
	commands->push_back("INC");
	commands->push_back("SUB 0");
	commands->push_back("JZERO " + to_string(label));

	conditionStruct *ret = new conditionStruct();
	ret->commands = commands;
	ret->index = label;
	label++;
	return ret;
}

int main(){
	yyparse();
	return 0;
}

void yyerror (const char *msg) {
    cout << "\n In line: "<< yylineo << "ERROR! " << msg << "\n";
}
