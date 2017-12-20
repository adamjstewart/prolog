(* Tokens *)
type token =
    (* Constants *)
      ATOM of string
    | INT of int
    | FLOAT of float
    | STRING of string
    (* Variables *)
    | VAR of string
    (* Symbols *)
    | RULE      (* :- *)
    | QUERY     (* ?- *)
    | PERIOD    (* .  *)
    | LPAREN    (* (  *)
    | RPAREN    (* )  *)
    | COMMA     (* ,  *)
    | SEMICOLON (* ;  *)
    (* Meta-characters *)
    | EOF

(* Constants *)
type const =
     Term of string * const list    (* atoms and compound terms *)
   | Variable of string             (* vatiables *)     
   | BoolConst of bool              (* booleans *)

(* Expressions *)
type exp =
     Fact of const               (* facts ie. cat(tom). *)
   | Rule of const * const       (* rules ie. cat(tom) :- true. *)

(* Declarations *)
type dec:
     Clause of exp           (* for adding facts/rules to db *)
   | Query of exp            (* for querying db *) 
