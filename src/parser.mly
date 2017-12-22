%{
    open Common

    (* The fact:
           Head.
       is equivalent to the rule:
           Head :- true.
    *)
    let fact_sugar p =
        Clause (
            p,
            ConstExp (BoolConst true)
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
%token SEMICOLON  /* ;  */

/* Meta-characters */
%token EOF

/* Start symbols */
%start clause

/* Types */
%type <Common.dec> clause
%type <Common.exp> predicate_list predicate term structure
%type <Common.exp list> term_list
%type <Common.const> constant

%%

clause:
    | p = predicate; PERIOD                             { fact_sugar p }
    | p = predicate; RULE; pl = predicate_list; PERIOD  { Clause (p, pl) }
    | QUERY; pl = predicate_list; PERIOD                { Query pl }

predicate_list:
    | p = predicate                                     { p }
    | pl = predicate_list; COMMA;     p = predicate     { ConjunctionExp (pl, p) }
    | pl = predicate_list; SEMICOLON; p = predicate     { DisjunctionExp (pl, p) }

predicate:
    | a = ATOM                                          { atom_sugar a }
    | a = ATOM; LPAREN; tl = term_list; RPAREN          { TermExp (a, tl) }

term_list:
    | t = term                                          { [t] }
    | tl = term_list; COMMA; t = term                   { tl @ [t] }

term:
    | c = constant                                      { ConstExp c }
    | a = ATOM                                          { atom_sugar a }
    | v = VAR                                           { VarExp v }
    | s = structure                                     { s }

structure:
    | a = ATOM; LPAREN; tl = term_list; RPAREN          { TermExp (a, tl) }

constant:
    | i = INT                                           { IntConst i }
    | f = FLOAT                                         { FloatConst f }
    | s = STRING                                        { StringConst s }
