%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int lineNum;
extern FILE *yyin;
void yyerror(char*);
%}

%union {
  char* letters; 
  int number;
}

%token <number> NUMBER
%token <letters> WORD
%token <letters> QUOTES
%type <number> expression

%token EQ
%token NEQ
%token LT
%token GT
%token LEQ
%token GEQ
%token IF
%token ELSE
%token WHILE
%token PRINT
%token INT
%token FUNCTION
%token MAIN
%token RETURN
%token EOL

%right '='
%left '+' '-'
%left '*' '/'

%start program

%%

expression  : expression '+' expression     {$$ = $1 + $3;}
            | expression '-' expression     {$$ = $1 - $3;}
            | expression '*' expression     {$$ = $1 * $3;}
            | expression '/' expression     {$$ = $1 / $3;}
            | '(' expression ')'            {$$ = $2;}
            | NUMBER                        {$$ = $1;}
            | WORD                          {$$ = $1;}
            ;

comparison  : expression EQ expression
            | expression NEQ expression
            | expression LT expression
            | expression GT expression
            | expression LEQ expression
            | expression GEQ expression
            ;

assignment  : INT WORD '=' expression   {printf(" %i\n", $4);}
            | INT WORD '=' functCall
            | WORD '=' expression       {printf(" %i\n", $3);}
            | WORD '=' functCall
            ;

print       : PRINT '(' QUOTES ')'
            ;

return      : RETURN expression ';' EOL
            ;

parameters  : parameter expression 
            ;

parameter   : parameters ','
            |
            ;

if          : IF '(' comparison ')' '{' EOL statements '}' EOL
            | IF '(' comparison ')' '{' EOL statements '}' ELSE '{' EOL statements '}' EOL
            ;

while       : WHILE '(' comparison ')' '{' EOL statements '}' EOL
            ;

function    : FUNCTION WORD '(' parameters ')' '{' EOL statements return '}' EOL
            ;

functCall   : WORD '(' parameters ')'
            ;

main        : MAIN '(' ')' '{' EOL statements '}'
            ;

statement   : assignment ';' EOL 
            | if
            | while
            | functCall ';' EOL
            | print ';' EOL
            ;

statements  : statements statement
            |
            ;

program     : function program
            | main
            ;

%%

int main(int argc, char** argv) {
  printf("\n > Syntactic analyzer for %s <\n", argv[1]);
  if (argc>1) yyin=fopen(argv[1],"r");
  yyparse();
  printf(" Ok\n\n");
}
void yyerror(char* msg) {
  printf(" Error at line %i: %s\n\n", lineNum, msg);
  exit(1);
}