%{
	#include <string>
	#include <cstring>
	#include <iostream>
	#include "checker.h"
	#include "parser.tab.h"
%}

%option noyywrap
%option yylineno
%option outfile="scanner.c" header-file="scanner.h"

%%

[ \t\n\r]+				{ /* Ignore whitespace and newline */ }


"string"				{ return KW_STRING; }
"integer"				{ return KW_INTEGER; }

"if"					{ return KW_IF; }
"then"					{ return KW_THEN; }
"elif"					{ return KW_ELIF; }
"else"					{ return KW_ELSE; }

"for"					{ return KW_FOR; }
"to"					{ return KW_TO; }
"do"					{ return KW_DO; }

"begin"					{ return KW_BEGIN; }
"end"					{ return KW_END; }

"break"					{ return KW_BREAK; }
"continue"				{ return KW_CONTINUE; }

"exit"					{ return KW_EXIT; }

"print"					{ return KW_PRINT; }

"readint"				{ return KW_READINT; }
"readstr"				{ return KW_READSTR; }

"length"				{ return KW_LENGTH; }
"position"				{ return KW_POSITION; }
"concatenate"			{ return KW_CONCATENATE; }
"substring"				{ return KW_SUBSTRING; }

"and"					{ return KW_AND; }
"or"					{ return KW_OR; }
"not"					{ return KW_NOT; }

"true"					{ return KW_TRUE; }
"false"					{ return KW_FALSE; }

":="					{ return ASSIGN; }
"=="					{ return EQ_STR; }
"!="					{ return NEQ_STR; }
"<>"					{ return NEQ_NUM; }
"<="					{ return LEQ_NUM; }
">="					{ return GEQ_NUM; }


[-+*/%()<>=,;]			{ return yytext[0]; }

[0-9]+				{ yylval.num = std::stoi(yytext); return NUM; }

\"[^\"]*\"				{ yylval.str = new std::string(yytext, 1, strlen(yytext) - 2); return STRING; }

[a-zA-Z_][a-zA-Z0-9_]* 	{ yylval.str = new std::string(yytext); return IDENT; }

.						{ std::cerr << "Lexical error: " << yytext << std::endl; }

%%