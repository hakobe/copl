
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
"evalto"              return 'EVALTO'
"let"                 return 'LET'
"in"                  return 'IN'
"if"                  return 'IF'
"then"                return 'THEN'
"else"                return 'ELSE'
[0-9]+                return 'INT'
"true"|"false"        return 'BOOL'
[a-z]+                return 'ID'
"|-"                  return '|-'
"="                   return '='
"*"                   return '*'
"-"                   return '-'
"+"                   return '+'
"<"                   return '<'
"("                   return '('
")"                   return ')'
","                   return ','
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%nonassoc LETEXP
%nonassoc IFEXP
%left '<'
%left '+' '-'
%left '*'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : env '|-' e EOF
        { return new yy.Node('ENVE', [$1, $3]); }
    ;

var
    : ID
        {$$ = new yy.Node('VAR', [], yytext)}
    ;

defvar
    : var '=' e
        {$$ = new yy.Node('DEFVAR', [ $1, $3 ])}
    ;

env
    : defvar
        {$$ = new yy.Node('ENV', [$1]);}
    | defvar ',' env
        {$$ = new yy.Node('ENV', [$1].concat($3.children));}
    |
        {$$ = new yy.Node('ENV', []);}
    ;

e
    : LET defvar IN e %prec LETEXP
        {$$ = new yy.Node('LET', [$2, $4]);}
    | IF e THEN e ELSE e %prec IFEXP
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
    | var
        {$$ = $1;}
    | '-' INT %prec UMINUS
        {$$ = new yy.Node('INT', [], -1 * parseInt(yytext));}
    | INT
        {$$ = new yy.Node('INT', [], parseInt(yytext));}
    | BOOL
        {$$ = new yy.Node('BOOL', [], yytext === 'true');}
    ;

