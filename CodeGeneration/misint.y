%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include "symbTable.h"

extern int lineNum;
extern FILE *yyin;
void yyerror(const char *);
int yylex(void);
int yydebug = 1;

FILE *file;
int memoryStart = 0x12000;
int functionMemory;
int auxMemory;
int labelNumber = 1;
int blockNumber = 0;
%}

%union {
  char *letters;
  int number;
  int labelNumber;
  int paramNumber;
  struct Node *aux;
}

%token <number> NUMBER
%token <letters> WORD
%token <letters> QUOTES
%type <number> expression
%type <paramNumber> parameter
%type <paramNumber> parameters

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

%right '='
%left '+' '-'
%left '*' '/'

%start program

%%

expression  : expression '+' expression     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1+R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression '-' expression     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1-R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | term
            ;

term        : term '*' value     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1*R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | term '/' value     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1/R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | value
            ;

value       : '(' expression ')'
            | NUMBER                        { fprintf(file,"\tR7=R7-4;\n\tI(R7)=%i;\n",$1); }
            | WORD                          {
                                              struct Node *aux = searchCat($1, var);
                                              if(aux == NULL) yyerror("variable not found");
                                              else fprintf(file,"\tR0=I(R6+%d);\n\tR7=R7-4;\n\tP(R7)=R0;\n", aux->address);
                                            }
            | functCall                     { fprintf(file,"\tR7=R7-4;\n\tI(R7)=R0;\n"); }
            ;

comparison  : expression EQ expression      { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1==R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression NEQ expression     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1!=R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression LT expression      { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1<R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression GT expression      { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1>R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression LEQ expression     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1<=R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            | expression GEQ expression     { fprintf(file,"\tR0=I(R7);\n\tR1=I(R7+4);\n\tR0=R1>=R0;\n\tR7=R7+4;\n\tI(R7)=R0;\n"); }
            ;

assignment  : INT WORD '='                  {
                                              struct Node *aux = searchCat($2, var);
                                              if(aux == NULL) {
                                                functionMemory=functionMemory-4;
                                                addAddress($2,var,functionMemory);
                                                fprintf(file,"\tR7=R7-4;\n");
                                              } else yyerror("variable already defined");
                                            }
              expression                    { fprintf(file,"\tR0=I(R7);\n\tR7=R7+4;\n\tI(R6+%d)=R0;\n", functionMemory); }
            | WORD '=' expression           { 
                                              struct Node *aux = searchCat($1, var);
                                              if(aux == NULL) yyerror("variable not found");
                                              else fprintf(file,"\tR0=I(R7);\n\tR7=R7+4;\n\tI(R6+%d)=R0;\n", aux->address);
                                            }

print       : PRINT '(' QUOTES ')'          {
                                              ++labelNumber;
                                              memoryStart=memoryStart-strlen($3);
                                              fprintf(file, "\tSTAT(%d)\n\tSTR(0x%x,%s);\n\tCODE(%d)\n\tR0=0x%x;\n\tR1=%d;\n\tGT(print_);\nL %d:\n", blockNumber, memoryStart, $3, blockNumber, memoryStart, labelNumber, labelNumber); 
                                              blockNumber++;
                                            }
            | PRINT '(' WORD ')'            {
                                              struct Node *aux = searchCat($3, var);
                                              if(aux == NULL) yyerror("variable not found");
                                              else {
                                                ++labelNumber;
                                                fprintf(file,"\tR0=I(R6%c%d);\n\tR1=%d;\n\tGT(printNumb_);\nL %d:\n", (aux->address < 0)? '-':'+', abs(aux->address), labelNumber, labelNumber);
                                              }
                                            }
            ;

return      : RETURN expression ';'         { fprintf(file,"\tR0=I(R7);\n\tR7=R7+4;\n"); }
            ;

parameters  : WORD parameter                { 
                                              struct Node *aux = searchCat($1, var); 
                                              if(aux == NULL) yyerror("variable not found");
                                              else fprintf(file,"\tR0=I(R6+%d);\n\tR7=R7-4;\n\tP(R7)=R0;\n", aux->address);
                                              $$ = $2 + 4;
                                            }
            ;

parameter   : ',' parameters                { $$ = $2; }
            |                               { $$ = 0; }
            ;

arguments   : argument INT WORD             {
                                              struct Node *aux = searchCat($3, var);
                                              if(aux == NULL) {
                                                addAddress($3, var, auxMemory);
                                                auxMemory = auxMemory + 4;
                                              }
                                              else yyerror("variable already defined");
                                            }
            ;

argument    : arguments ','
            |
            ;

beginIf     : IF '(' comparison ')' '{'     {
                                              $<labelNumber>$=++labelNumber;
                                              fprintf(file,"\tR0=I(R7);\n\tR7=R7+4;\n\tIF(!R0) GT(%d);\n", $<labelNumber>$);
                                            }
            ;

if          : beginIf statements '}'        { fprintf(file,"L %d:\n",$<labelNumber>1); }
            | beginIf statements '}'
              ELSE '{'                      {
                                              $<labelNumber>$=++labelNumber;
                                              fprintf(file,"\tGT(%d);\nL %d:\n", $<labelNumber>$, $<labelNumber>1);
                                            }
              statements '}'                { fprintf(file,"L %d:\n",$<labelNumber>6); }
            ;

while       : WHILE '('                     {
                                              $<labelNumber>$=++labelNumber;
                                              fprintf(file,"L %d:\n", $<labelNumber>$);
                                            }
              comparison ')' '{'            {
                                              $<labelNumber>$=++labelNumber;
                                              fprintf(file,"\tR0=I(R7);\n\tR7=R7+4;\n\tIF(!R0) GT(%d);\n", $<labelNumber>$);
                                            }
              statements '}'                { fprintf(file,"\tGT(%d);\nL %d:\n", $<labelNumber>3, $<labelNumber>7); }
            ;

function    : FUNCTION WORD '('                       {
                                                        struct Node *aux = searchCat($2, func);
                                                        if(aux == NULL) {
                                                          $<aux>$ = addAddress($2, func, ++labelNumber);
                                                          functionMemory = 0;
                                                          auxMemory = 8;
                                                          fprintf(file,"L %d:\n\tR6=R7;\n", labelNumber);
                                                        }
                                                        else yyerror("function already defined");
                                                      }
              arguments ')' '{'                       { $<aux>4->functArguments = auxMemory-8; }
              statements return '}'                   {
                                                        showInConsole($2);
                                                        freeMemory();
                                                        fprintf(file,"\tR7=R6;\n\tR6=P(R7+4);\n\tR5=I(R7);\n\tGT(R5);\n");
                                                      }
            ;

functCall   : WORD '(' parameters ')'       {
                                              struct Node *aux = searchCat($1, func);
                                              if(aux == NULL) yyerror("function not found");
                                              else {
                                                labelNumber++;
                                                fprintf(file,"\tR7=R7-8;\n\tP(R7+4)=R6;\n\tP(R7)=%d;\n\tGT(%d);\nL %d:\n\tR7=R7+%d;\n", labelNumber, aux->address, labelNumber, 8+$3);
                                              }
                                            }
            ;

main        : MAIN '(' ')' '{'              { fprintf(file, "L 1: \n"); functionMemory = 0; }
              statements '}'                {
                                              showInConsole("Main");
                                              fprintf(file, "\tGT(-2);\nL 0:\n\tR6=R7;\n\tGT(1);\n");
                                            }
            ;

statements  : statements statement
            |
            ;

statement   : if
            | while
            | print ';'
            | assignment ';'
            ;

program     : function program
            | main
            ;

%%

int main(int argc, char** argv) {
  printf("\n > Syntactic analyzer and symbol table for %s <\n", argv[1]);
  if (argc>1)
  {
    yyin=fopen(argv[1],"r");
    file = fopen("myQ.q.c", "w");
    fprintf(file, "#include \"Q.h\" \nBEGIN\n");
    yyparse();
    printf(" Ok\n\n");
    fprintf(file, "END\n");
    fclose(file);
  }
}
void yyerror(const char *msg) {
  showInConsole("ERROR");
  printf(" Error at line %i: %s\n\n", lineNum, msg);
  exit(1);
}
