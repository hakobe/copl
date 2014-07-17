
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
"evalto"              return 'EVALTO'
"if"                  return 'IF'
"then"                return 'THEN'
"else"                return 'ELSE'
[0-9]+                return 'INT'
"true"|"false"        return 'BOOL'
"*"                   return '*'
"-"                   return '-'
"+"                   return '+'
"<"                   return '<'
"("                   return '('
")"                   return ')'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%nonassoc IFEXP
%left '<'
%left '+' '-'
%left '*'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { return $1; }
    ;

e
    : IF e THEN e ELSE e %prec IFEXP
        {$$ = new yy.Node('IF', [$2, $4, $6]);}
    | e '<' e
        {$$ = new yy.Node('LT', [$1, $3]);}
    | e '+' e
        {$$ = new yy.Node('PLUS', [$1, $3]);}
    | e '-' e
        {$$ = new yy.Node('MINUS', [$1, $3]);}
    | e '*' e
        {$$ = new yy.Node('TIMES', [$1, $3]);}
    | '(' e ')'
        {$$ = $2;}
    | '-' INT %prec UMINUS
        {$$ = new yy.Node('INT', [], -1 * parseInt(yytext));}
    | INT
        {$$ = new yy.Node('INT', [], parseInt(yytext));}
    | BOOL
        {$$ = new yy.Node('BOOL', [], yytext === 'true');}
    ;

