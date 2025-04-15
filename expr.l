%{
#include "expr.tab.h"
#include <stdlib.h>
#include <string.h>
%}

DIGIT   [0-9]
ID      [a-zA-Z_][a-zA-Z0-9_]*

%%
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }

"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }
"<"         { return '<'; }
">"         { return '>'; }

"&&"        { return AND; }
"||"        { return OR; }
"!"         { return NOT; }

{DIGIT}+(\.{DIGIT}+)?    { yylval.fval = atof(yytext); return FLOAT; }
{ID}        { yylval.sval = strdup(yytext); return ID; }

"="         { return '='; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
[+\-*/]     { return *yytext; }

","         { return ','; }  // Added for handling commas

[ \t\r]     ; // Ignore whitespace
\n          { return '\n'; }

.           { printf("Invalid character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}
