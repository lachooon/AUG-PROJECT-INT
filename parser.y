%{
	#include <iostream>
	#include <string>
	#include <map>
	#include "checker.h"

	extern int yylex();
	extern int yylineno;
	void yyerror(const char* s);

	std::map<std::string, VariableInfo> symbol_table;
%}

%code requires
{
	#include <string>
}

%union
{
	int num;
	std::string* str;
	Node* node;
}


%token <num> NUM
%token <str> STRING IDENT

%token KW_STRING KW_INTEGER
%token KW_IF KW_THEN KW_ELIF KW_ELSE
%token KW_FOR KW_TO KW_DO
%token KW_BEGIN KW_END
%token KW_BREAK KW_CONTINUE KW_EXIT
%token KW_PRINT
%token KW_READINT KW_READSTR
%token KW_LENGTH KW_POSITION KW_CONCATENATE KW_SUBSTRING
%token KW_AND KW_OR KW_NOT
%token KW_TRUE KW_FALSE

%token ASSIGN ":="
%token EQ_STR "=="
%token NEQ_STR "!="

%token NEQ_NUM "<>"
%token LEQ_NUM "<="
%token GEQ_NUM ">="


%type <node> program declarations declaration instr simple_instr
%type <node> assign_stat if_stat if_options for_stat output_stat
%type <node> num_expr t_num_expr f_num_expr
%type <node> str_expr bool_expr t_bool_expr f_bool_expr
%type <num> num_rel str_rel


%%


program:
	declarations instr { $$ = nullptr; }
	;

declarations:
	declarations declaration ';' { $$ = nullptr; }
	| { $$ = nullptr; }
	;

declaration:
	KW_STRING IDENT
	{
		$$ = new DeclarationNode(*$2, TYPE_STRING, yylineno);
		$$->checkType();
		delete $2;
	}
	| KW_INTEGER IDENT
	{
		$$ = new DeclarationNode(*$2, TYPE_INT, yylineno);
		$$->checkType();
		delete $2;
	}
	;

instr:
	instr simple_instr ';' { $$ = nullptr; }
	| { $$ = nullptr; }
	;

simple_instr:
	assign_stat { $$ = nullptr; }
	| if_stat { $$ = nullptr; }
	| for_stat { $$ = nullptr; }
	| KW_BEGIN instr KW_END { $$ = nullptr; }
	| output_stat { $$ = nullptr; }
	| KW_BREAK { $$ = nullptr; }
	| KW_CONTINUE { $$ = nullptr; }
	| KW_EXIT { $$ = nullptr; }
	;

assign_stat:
	IDENT ASSIGN num_expr
	{
		$$ = new AssignmentNode(*$1, $3, yylineno);
		$$->checkType();
		delete $1;
	}
	| IDENT ASSIGN str_expr
	{
		$$ = new AssignmentNode(*$1, $3, yylineno);
		$$->checkType();
		delete $1;
	}
	;

if_stat:
	KW_IF bool_expr KW_THEN simple_instr if_options { $$ = nullptr; }
	;

if_options:
	KW_ELIF bool_expr KW_THEN simple_instr if_options { $$ = nullptr; }
	| KW_ELSE simple_instr { $$ = nullptr; }
	| { $$ = nullptr; }
	;

for_stat:
	KW_FOR IDENT ASSIGN num_expr KW_TO num_expr KW_DO simple_instr
	{
		if (symbol_table.find(*$2) != symbol_table.end())
		{
			symbol_table[*$2].lines_used.push_back(yylineno);
		}
		else
		{
			std::cerr << "Line: " << yylineno << ", variable: " << *$2 << " was not declared" << std::endl;
		}
		delete $2;
		
		if ($4) $4->checkType();
		if ($6) $6->checkType();
		
		$$ = nullptr;
	}
	;

output_stat:
	KW_PRINT '(' num_expr ')'
	{
		if ($3) $3->checkType();
		$$ = nullptr;
	}
	| KW_PRINT '(' str_expr ')'
	{
		if ($3) $3->checkType();
		$$ = nullptr;
	}
	;

num_expr:
	num_expr '+' t_num_expr
	{
		if ($3) $3->checkType();
		$$ = $1;
	}
	| num_expr '-' t_num_expr
	{
		if ($3) $3->checkType();
		$$ = $1;
	}
	| t_num_expr { $$ = $1; }
	;

t_num_expr:
	t_num_expr '*' f_num_expr
	{
		if ($3) $3->checkType();
		$$ = $1;
	}
	| t_num_expr '/' f_num_expr
	{
		if ($3) $3->checkType();
		$$ = $1;
	}
	| t_num_expr '%' f_num_expr
	{
		if ($3) $3->checkType();
		$$ = $1;
	}
	| f_num_expr { $$ = $1; }
	;

f_num_expr:
	NUM
	{
		$$ = new LiteralNode(TYPE_INT);
	}
	| IDENT
	{
		$$ = new IdentifierNode(*$1, yylineno);
		delete $1;
	}
	| KW_READINT
	{
		$$ = new LiteralNode(TYPE_INT);
	}
	| '-' num_expr
	{
		$$ = $2;
	}
	| '(' num_expr ')'
	{
		$$ = $2;
	}
	| KW_LENGTH '(' str_expr ')'
	{
		if ($3) $3->checkType();
		$$ = new LiteralNode(TYPE_INT);
	}
	| KW_POSITION '(' str_expr ',' str_expr ')'
	{
		if ($3) $3->checkType();
		if ($5) $5->checkType();
		$$ = new LiteralNode(TYPE_INT);
	}
	;

str_expr:
	STRING
	{
		$$ = new LiteralNode(TYPE_STRING);
		delete $1;
	}
	| IDENT
	{
		$$ = new IdentifierNode(*$1, yylineno);
		delete $1;
	}
	| KW_READSTR
	{
		$$ = new LiteralNode(TYPE_STRING);
	}
	| KW_CONCATENATE '(' str_expr ',' str_expr ')'
	{
		if ($3) $3->checkType();
		if ($5) $5->checkType();
		$$ = new LiteralNode(TYPE_STRING);
	}
	| KW_SUBSTRING '(' str_expr ',' num_expr ',' num_expr ')'
	{
		if ($3) $3->checkType();
		if ($5) $5->checkType();
		if ($7) $7->checkType();
		$$ = new LiteralNode(TYPE_STRING);
	}
	;

num_rel:
	'=' { $$ = '='; }
	| '<' { $$ = '<'; }
	| LEQ_NUM { $$ = LEQ_NUM; }
	| '>' { $$ = '>'; }
	| GEQ_NUM { $$ = GEQ_NUM; }
	| NEQ_NUM { $$ = NEQ_NUM; }
	;

str_rel:
	EQ_STR { $$ = EQ_STR; }
	| NEQ_STR { $$ = NEQ_STR; }
	;

bool_expr:
	bool_expr KW_OR t_bool_expr { $$ = nullptr; }
	| t_bool_expr { $$ = $1; }
	;

t_bool_expr:
	t_bool_expr KW_AND f_bool_expr { $$ = nullptr; }
	| f_bool_expr { $$ = $1; }
	;

f_bool_expr:
	KW_TRUE { $$ = nullptr; }
	| KW_FALSE { $$ = nullptr; }
	| '(' bool_expr ')' { $$ = $2; }
	| KW_NOT bool_expr { $$ = nullptr; }
	| num_expr num_rel num_expr
	{
		if ($1) $1->checkType();
		if ($3) $3->checkType();
		$$ = nullptr;
	}
	| str_expr str_rel str_expr
	{
		if ($1) $1->checkType();
		if ($3) $3->checkType();
		$$ = nullptr;
	}
	;


%%


void yyerror(const char* s)
{
	std::cerr << "Parser error: " << s << ", line: " << yylineno << std::endl;
}

void printSymbolTable()
{
	std::cout << "VARIABLE SUMMARY" << std::endl;

	for (auto const& [variable_name, info] : symbol_table)
	{
		std::cout << "Variable: " << variable_name << " | Type: ";

		if (info.type == TYPE_INT) { std::cout << "INTEGER"; }
		else if (info.type == TYPE_STRING) { std::cout << "STRING"; }
		else { std::cout << "UNKNOWN"; }

		std::cout << " | Lines used: ";
		for (int line : info.lines_used)
		{
			std::cout << line << " ";
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
}

int main()
{
	if (yyparse() == 0)
	{
		std::cout << "Parsing has ended successfully" << std::endl;
		printSymbolTable();
	}
	
	return 0;
}