open Ast
open Common
let (fresh, reset) =
   let nxt = ref 0 in
   let f () = (nxt := !nxt + 1; string_of_int (!nxt)) in
   let r () = nxt := 0 in
    (f, r) 

let found_solution = ref false
                   
let rec find_vars q  = match q with [] -> []
                                  | (x::xs) -> (match x with VarExp(v) -> [x] @ (find_vars xs)
                                                          | ConstExp(c) -> (find_vars xs)
                                                          | TermExp(s,el) -> (find_vars el) @ (find_vars xs))
                                            
(* from https://rosettacode.org/wiki/Remove_duplicate_elements#OCaml *)
let uniq l =
  let rec tail_uniq a l =
    match l with
      | [] -> a
      | hd::tl -> tail_uniq (hd::a) (List.filter (fun x -> x  != hd) tl) in
  tail_uniq [] l

let rec sub_lift_goal sub g =
  match g with
  | VarExp(v) ->(match  List.assoc_opt g sub with None -> VarExp(v)
                                               | Some(i) -> i)
  | TermExp(s,el) -> TermExp(s, List.map (fun g1 -> sub_lift_goal sub g1) el)
  | _  -> g
                                              
let rec sub_lift_goals sub g = List.map (fun g1 -> sub_lift_goal sub g1) g
let rec rename_vars_in_clause c =
  match c with
  | Clause(h,b) ->
     let head_vars = find_vars [h] in
     let body_vars = find_vars b in
     let vars = uniq (head_vars @ body_vars) in
     let sub = List.map (fun x -> (x, VarExp(fresh()))) vars in
     Clause(sub_lift_goal sub h, sub_lift_goals sub b)
  | _ -> raise(Failure "not needed")
let add_clause_to_db (dec,db) =
    match dec with
    | Clause (h,b) -> (match h with TermExp("true",_) -> print_string "can't reassign true predicate\n"; db
                                 | _ -> db @ [dec])
    | _ -> raise(Failure "not needed")
let rec pairandcat sargs targs c = match sargs with [] -> c
                                                  | (s::ss) -> match targs with (t::ts) -> pairandcat ss ts ((s,t)::c)
                                                                             |  _ -> raise(Failure "not needed")
let rec replace c sub = match c with [] -> []
                                   | ((s,t)::xs) -> (sub_lift_goal sub s, sub_lift_goal sub t)::(replace xs sub)
let rec occurs s t = match s with VarExp(n) -> (match t with VarExp(m) -> n = m
                                                          | TermExp(st,el) -> List.fold_left (fun acc v -> acc || (occurs s v)) false el
                                                          | _ -> false)
                                |  _ -> raise(Failure "not needed")
let rec unify constraints =
  match constraints with
  | [] -> Some([])
  | ((s,t)::c') -> if s = t
                  then unify c'
                  else match s with VarExp(n) ->
                                    if (occurs s t)
                                    then None
                                    else let sub = [(s,t)] in
                                         let c'' = replace c' sub in
                                         let phi = unify c'' in
                                         (match phi with None -> None
                                                       | Some(l) -> Some((s, sub_lift_goal l t)::l))
                                  | TermExp(sname,sargs) ->
                                     (match t with VarExp(k) -> unify ((t,s)::c')
                                                 | TermExp(tname,targs) ->
                                                    if (tname = sname && List.length targs = List.length sargs)
                                                    then unify (pairandcat sargs targs c')
                                                    else None
                                                 | _ -> None)
                                  | _ -> None

    
let rec eval_query (q, db, env, orig_query_vars, orig_vars_num) =
    match q with 
    | [] -> (match unify env with
            | Some(e2) ->
              found_solution := true;
              (if (orig_vars_num > 0) then print_string "====================\n");
          
              List.fold_right (fun d r ->
                 ( match d with VarExp(v) ->
                     (match List.assoc_opt (VarExp(v)) e2 with
                      | Some(TermExp(st,el)) ->  print_string (v ^ " = " ^ (string_of_atom ((TermExp(st,el))) ^ "\n")); r
                      | Some(VarExp(v2)) ->  print_string (v ^ " is free\n");r
                      | Some(_) -> raise(Failure "not needed")
                      | None -> print_string (v ^ " is free\n");r)
                              | _ ->  raise(Failure "not needed")
                 )
                )
                       orig_query_vars ();
           
             (if (orig_vars_num > 0) then print_string "====================\n");
            | _ -> ())
    | (g1::gl) ->
       (for i = 0 to ((List.length db)-1) do
          let rulei = List.nth db i in
          match (rename_vars_in_clause rulei) with
          | Clause(h,b) ->
            (match unify [(g1, h)] with
             | Some(s) ->
                if (List.length b = 1 )
                then
                  (match b with ((ConstExp (BoolConst true))::ys) ->
                     eval_query (sub_lift_goals s gl, db, (s@env), orig_query_vars,  orig_vars_num)
                               | _ ->  eval_query ((sub_lift_goals s b) @ (sub_lift_goals s gl), db, (s@env), orig_query_vars, orig_vars_num))
                else 
                  eval_query ((sub_lift_goals s b) @ (sub_lift_goals s gl), db, (s@env), orig_query_vars,  orig_vars_num)
             | _ -> ()
            )
          |  _ -> raise(Failure "not needed")
                         
        done
       )
 

  
let eval_dec (dec, db) =
    match dec with
    | Clause(h,b) -> add_clause_to_db (dec, db)
    | Query(b) -> (let orig_vars = uniq (find_vars b) in
                 let orig_vars_num = List.length orig_vars in
                
                 eval_query (b, db, [], orig_vars, orig_vars_num);
                    (if (!found_solution = false)
                    then print_string "false\n"
                                      (*else (if (orig_vars_num = 0) then (print_string "true\n"); found_solution := false));*)
                     else ( (print_string "true\n"); found_solution := false));
                    db)
   
