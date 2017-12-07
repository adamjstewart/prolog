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
      AtomConst of string    (* atoms    *)
    | IntConst of int        (* integers *)
    | FloatConst of float    (* floats   *)
    | StringConst of string  (* strings  *)
    | BoolConst of bool      (* booleans *)

(* Expressions *)
type exp =
      VarExp of string              (* variables                *)
    | ConstExp of const             (* constants                *)
    | RuleExp of exp * exp          (* Head :- Body.            *)
    | FactExp of exp                (* Head.                    *)
    | CompoundTermExp of exp * exp  (* functor(arg1, arg2, ...) *)
    | ListExp of exp * exp          (* arg1, arg2               *)
