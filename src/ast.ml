(* Constants *)
type const =
    | IntConst of int        (* integers *)
    | FloatConst of float    (* floats   *)
    | StringConst of string  (* strings  *)
    | BoolConst of bool      (* booleans *)

(* Expressions *)
type exp =
    | VarExp of string              (* variables                *)
    | ConstExp of const             (* constants                *)
    | TermExp of string * exp list  (* functor(arg1, arg2, ...) *)
    | ConjunctionExp of exp * exp   (* term, term               *)
    | DisjunctionExp of exp * exp   (* term; term               *)

(* Declarations *)
type dec =
    | Clause of exp * exp   (* Head :- Body. *)
    | Query of exp          (* ?- Body.      *)

(* Results *)
type res =
    | ClauseRes of dec list
 (* | QueryRes of *)  (*have to figure this out*)
