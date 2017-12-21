open Common



let add_clause_to_db (dec,db) = match dec with Clause(h,b) -> ClauseRes((Clause(h,b))::db)
  
let eval_dec (dec, db) = match dec with Clause(h,b) -> add_clause_to_db(dec, db)
                                      | Query(b) -> raise (Failure "Not Implementing right now")


(*Helper functions, maybe need to be refined more and put in common.ml*)

let print_const x = match x with
  | IntConst(i)  -> print_int i; print_string ("\n")
  | FloatConst(f) -> print_float f; print_string ("\n")
  | StringConst(s) -> print_string s; print_string ("\n")
  | BoolConst(b)  -> print_string (string_of_bool b); print_string ("\n")
let rec print_exp_list l = match l with [] -> ()
                                      | (x::xs) -> print_exp (x); print_exp_list (xs)
and print_exp x = match x with
  | VarExp(v) -> print_string ("Var: " ^ v ^ "\n")
  | ConstExp(c) -> print_string ("Const: "); print_const (c)
  | TermExp(s,e) -> print_string ("Term: " ^ s ^ "\n"); print_exp_list (e)
  | ConjunctionExp(e1,e2) -> print_string ("Conj:\n"); print_exp (e1); print_exp (e2)
  | DisjunctionExp(e1,e2) -> print_string ("Disj:\n"); print_exp (e1); print_exp (e2)

let print_dec x = match x with Clause(h,b) -> print_string ("CLAUSE:\n"); print_exp (h); print_exp (b)
                             |  Query(b) -> raise (Failure "Not Implementing right now")



let rec print_db x = match x with [] ->  ()
                                | (y::ys) -> print_dec (y); print_db (ys) 

