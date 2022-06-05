%{
int lineNum = 1;
void showError(char*);

#define EQ 257
#define NEQ 258
#define LT 259
#define GT 260
#define LEQ 261
#define GEQ 262

#define IF 263
#define ELSE 264
#define WHILE 265
#define PRINT 266
#define INT 267
#define FUNCTION 268
#define MAIN 269
#define NUMBER 270
#define LETTER 271
#define QUOTES 272
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

\"[^"]*\"           { return QUOTES; }
","                 { return ','; }
";"                 { return ';'; }
\n                  { lineNum++; }
[ \t]
\r

"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"print"             { return PRINT; }

"int"               { return INT; }
"function"          { return FUNCTION; }
"main"              { return MAIN; }

['+'-]?{digit}+     { return NUMBER; }
{letter}+           { return LETTER; }
.                   { char s[4]; sprintf(s, "'%c'", yytext[0]); showError(s); }
<<EOF>>             { return 0; }
%%

int main(int argc, char** argv) {
  printf("\n > Lexical analyzer for %s <\n", argv[1]);
  int s;
  if(argc>1) yyin=fopen(argv[1],"r"); /* else yyin=stdin */ 
  do {
      printf(" %i: %i \n", lineNum, s=yylex()); 
  } 
  while(s != 0);
  printf("\n");
  return 0;
}
void showError(char* msg) {
  printf(" Unknown character at line %i: %s\n", lineNum, msg);
}