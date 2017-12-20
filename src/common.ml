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

(* Declarations *)
type dec:
      Clause of exp           (* for adding facts/rules to db *)
    | Query of exp            (* for querying db *) 


(* Constants *)
type atomic =
      Term of string * atomic list    (* atoms and compound terms *)
    | Variable of string             (* vatiables *)     
    | BoolConst of bool              (* booleans *)
    | IntConst of int        (* integers *)
    | FloatConst of float    (* floats   *)
    | StringConst of string  (* strings  *)

(* body of a rule*)
type pred =
      Single of atomic               (* ie cat(X) *)
    | Conjunction of pred * pred     (* ie parent_child(Z, X), parent_child(Z, Y) *)
    | Disjunction of pred * pred     (* ie parent_child(Z, X); parent_child(Z, Y) *)
(* head of a rule*)
type head =
      Head of atomic 
(* Expressions: facts adn rules can become one later but this is fine *)
type exp =
      Fact of head               (* facts ie. cat(tom). *)
    | Rule of head * pred       (* rules ie. cat(tom) :- true. *)


