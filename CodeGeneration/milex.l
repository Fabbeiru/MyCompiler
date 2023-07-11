%{
#include <stdio.h>
#include <string.h>
#include "misint.tab.h"
#include <errno.h>

int lineNum = 1;
%}

%option noyywrap

letter [a-zA-Z]
digit  [0-9]

%%
"="                 { return '='; }
"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"%"                 { return '%'; }
"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }

"=="                { return EQ; }
"!="                { return NEQ; }
"<"                 { return LT; }
">"                 { return GT; }
"<="                { return LEQ; }
">="                { return GEQ; }

\"[^"]*\"           { yylval.letters=strdup(yytext); return QUOTES; }
","                 { return ','; }
";"                 { return ';'; }
\n                  { lineNum++; }
[ \t]
\r
"//".*

"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"print"             { return PRINT; }

"int"               { return INT; }
"function"          { return FUNCTION; }
"main"              { return MAIN; }
"return"            { return RETURN; }

['+'-]?{digit}+     { yylval.number=atoi(strdup(yytext)); return NUMBER; }
{letter}+           { yylval.letters=strdup(yytext); return WORD; }
.                   { perror("lexical error"); }
<<EOF>>             { return 0; }
%%
