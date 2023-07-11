%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include "symbTable.h"

int yydebug = 1;

extern int lineNum;
extern FILE *yyin;
void yyerror(const char *);
int yylex(void);
%}

%union {
  char *letters; 
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

expression  : expression '+' expression
            | expression '-' expression
            | expression '*' expression
            | expression '/' expression
            | '(' expression ')'
            | NUMBER
            | WORD                          { if(searchCat($1, var) == NULL) yyerror("variable not found"); }
            ;

comparison  : expression EQ expression
            | expression NEQ expression
            | expression LT expression
            | expression GT expression
            | expression LEQ expression
            | expression GEQ expression
            ;

assignment  : INT WORD '=' expression       {
                                              struct Node *aux = searchCat($2, var);
                                              if(aux == NULL) insert($2, var);
                                              else yyerror("variable already defined");
                                            }
            | INT WORD '=' functCall        {
                                              struct Node *aux = searchCat($2, var);
                                              if(aux == NULL) insert($2, var);
                                              else yyerror("variable already defined");
                                            }
            | WORD '=' expression           { if(searchCat($1, var) == NULL) yyerror("variable not found"); }
            | WORD '=' functCall            { if(searchCat($1, var) == NULL) yyerror("variable not found"); }
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

arguments   : argument INT WORD             {
                                              struct Node *aux = searchCat($3, var);
                                              if(aux == NULL) insert($3, var);
                                              else yyerror("variable already defined");
                                            }
            ;

argument    : arguments ','
            |
            ;

if          : IF '(' comparison ')' '{' EOL statements '}' EOL
            | IF '(' comparison ')' '{' EOL statements '}' ELSE '{' EOL statements '}' EOL
            ;

while       : WHILE '(' comparison ')' '{' EOL statements '}' EOL
            ;

function    : FUNCTION WORD '(' arguments ')'         {
                                                        struct Node *aux = searchCat($2, func);
                                                        if(aux == NULL) insert($2, func);
                                                        else yyerror("function already defined");
                                                      }
              '{' EOL statements return '}' EOL       { showInConsole($2); }
            ;

functCall   : WORD '(' parameters ')'       { if(searchCat($1, func) == NULL) yyerror("function not found"); }
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
            | main                          { showInConsole("Main"); }
            ;

%%

int main(int argc, char** argv) {
  printf("\n > Syntactic analyzer and symbol table for %s <\n", argv[1]);
  if (argc>1) yyin=fopen(argv[1],"r");
  yyparse();
  printf(" Ok\n\n");
}
void yyerror(const char *msg) {
  showInConsole("ERROR");
  printf(" Error at line %i: %s\n\n", lineNum, msg);
  exit(1);
}
