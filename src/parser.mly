%{
    open Ast

    (* The fact:
           Head.
       is equivalent to the rule:
           Head :- true.
    *)
    let fact_sugar p =
        Clause (
            p,
            [TermExp ("true", [])]
        )

    (* An atom can be regarded as a compound term with arity zero *)
    let atom_sugar a =
        TermExp (
            a,
            []
        )
%}

/* Refer to:

   https://www.cs.uni-potsdam.de/wv/lehre/Material/Prolog/Eclipse-Doc/userman/node140.html
   https://github.com/simonkrenger/ch.bfh.bti7064.w2013.PrologParser/blob/master/doc/prolog-bnf-grammar.txt

   for a description of the grammar */

/* Tokens */

/* Constants */
%token <int> INT
%token <float> FLOAT
%token <string> STRING ATOM

/* Variables */
%token <string> VAR

/* Symbols */
%token RULE       /* :- */
%token QUERY      /* ?- */
%token PERIOD     /* .  */
%token LPAREN     /* (  */
%token RPAREN     /* )  */
%token COMMA      /* ,  */

/* Meta-characters */
%token EOF

/* Start symbols */
%start clause

/* Types */
%type <Ast.dec> clause
%type <Ast.exp> predicate term structure
%type <Ast.exp list> term_list predicate_list
%type <Ast.const> constant

%%

clause:
    | p = predicate; PERIOD                             { fact_sugar p }
    | p = predicate; RULE; pl = predicate_list; PERIOD  { Clause (p, pl) }
    | QUERY; pl = predicate_list; PERIOD                { Query pl }

predicate_list:
    | p = predicate                                     { [p] }
    | p = predicate; COMMA; pl = predicate_list         { p :: pl }

predicate:
    | a = ATOM                                          { atom_sugar a }
    | s = structure                                     { s }

structure:
    | a = ATOM; LPAREN; RPAREN                          { atom_sugar a }
    | a = ATOM; LPAREN; tl = term_list; RPAREN          { TermExp (a, tl) }

term_list:
    | t = term                                          { [t] }
    | t = term; COMMA; tl = term_list                   { t :: tl }

term:
    | c = constant                                      { ConstExp c }
    | a = ATOM                                          { atom_sugar a }
    | v = VAR                                           { VarExp v }
    | s = structure                                     { s }

constant:
    | i = INT                                           { IntConst i }
    | f = FLOAT                                         { FloatConst f }
    | s = STRING                                        { StringConst s }
