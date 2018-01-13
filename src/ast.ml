(* Constants *)
type const =
    | IntConst of int        (* integers *)
    | FloatConst of float    (* floats   *)
    | StringConst of string  (* strings  *)

(* Expressions *)
type exp =
    | VarExp of string              (* variables                *)
    | ConstExp of const             (* constants                *)
    | TermExp of string * exp list  (* functor(arg1, arg2, ...) *)

(* Declarations *)
type dec =
    | Clause of exp * (exp list)  (* Head :- Body. *)
    | Query of (exp list)         (* ?- Body.      *)

