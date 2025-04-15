%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex();
void yyerror(const char* s);

// Symbol table for variable storage
typedef struct {
    char* name;
    double value;
} Variable;

Variable symtab[100];
int var_count = 0;

double get_var_value(const char* name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(symtab[i].name, name) == 0)
            return symtab[i].value;
    }
    fprintf(stderr, "Undefined variable: %s\n", name);
    exit(1);
}

void set_var_value(const char* name, double val) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(symtab[i].name, name) == 0) {
            symtab[i].value = val;
            return;
        }
    }
    symtab[var_count].name = strdup(name);
    symtab[var_count].value = val;
    var_count++;
}
%}

%union {
    double fval;
    char* sval;
}

%token <fval> FLOAT
%token <sval> ID
%token IF ELSE WHILE
%token EQ NE LE GE AND OR NOT

%type <fval> expr stmt

%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%right NOT
%right '='

%%
input:
      /* empty */
    | input stmt '\n'
    ;

stmt:
      expr                            { printf("Result = %.2f\n", $1); }
    | ID '=' expr                     { set_var_value($1, $3); printf("%s = %.2f\n", $1, $3); free($1); }
    | IF '(' expr ')' stmt            { if ($3) { $$ = $5; } }
    | IF '(' expr ')' stmt ELSE stmt { if ($3) { $$ = $5; } else { $$ = $7; } }
    | WHILE '(' expr ')' stmt        { while ($3) { $$ = $5; } }
    | '{' input '}'                   { /* No value to return */ }
    ;

expr:
      FLOAT             { $$ = $1; }
    | ID                { $$ = get_var_value($1); free($1); }
    | ID '(' expr ')'   {
                            if (strcmp($1, "sqrt") == 0) $$ = sqrt($3);  // Single argument function
                            else if (strcmp($1, "sin") == 0) $$ = sin($3);
                            else if (strcmp($1, "cos") == 0) $$ = cos($3);
                            else if (strcmp($1, "log") == 0) $$ = log($3);
                            else { fprintf(stderr, "Unknown function: %s\n", $1); exit(1); }
                            free($1);
                        }
    | ID '(' expr ',' expr ')'   {
                            if (strcmp($1, "pow") == 0) $$ = pow($3, $5);  // Corrected for two arguments
                            else { fprintf(stderr, "Unknown function: %s\n", $1); exit(1); }
                            free($1);
                        }
    | expr '+' expr     { $$ = $1 + $3; }
    | expr '-' expr     { $$ = $1 - $3; }
    | expr '*' expr     { $$ = $1 * $3; }
    | expr '/' expr     { if ($3 == 0) { yyerror("Division by zero!"); exit(1); } $$ = $1 / $3; }
    | expr EQ expr      { $$ = ($1 == $3); }
    | expr NE expr      { $$ = ($1 != $3); }
    | expr '<' expr     { $$ = ($1 < $3); }
    | expr '>' expr     { $$ = ($1 > $3); }
    | expr LE expr      { $$ = ($1 <= $3); }
    | expr GE expr      { $$ = ($1 >= $3); }
    | expr AND expr     { $$ = ($1 && $3); }
    | expr OR expr      { $$ = ($1 || $3); }
    | NOT expr          { $$ = (!$2); }
    | '(' expr ')'      { $$ = $2; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Mini Compiler Ready. Enter expressions:\n");
    yyparse();
    return 0;
}
