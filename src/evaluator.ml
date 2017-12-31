open Ast

let (fresh, reset) =
   let nxt = ref 0 in
   let f () = (nxt := !nxt + 1; string_of_int (!nxt)) in
   let r () = nxt := 0 in
    (f, r) 




let add_clause_to_db (dec,db) =
    match dec with
    Clause (h,b) -> dec :: db

(*let eval_query (q, db, env) =
    match q with 
    | TermExp(s,el) -> loop_term_in_db (s,e1) db env
    | ConjunctionExp(e1,e2) -> (match eval_query (lift_sub_goal e1 env) with
                               | None -> None
                               | Some(s1) -> eval_query (lift_sub_goal (lift_sub_goal e2 env) s1)
 *)
let eval_dec (dec, db) =
    match dec with
    | Clause(h,b) -> (add_clause_to_db (dec, db), None)
    | Query(b) -> raise (Failure "not implemented")
