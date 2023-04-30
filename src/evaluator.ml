open Ast
open Common


(*
   fresh:
      * takes in:
          unit
      * returns a string of the increment of the counter
   reset:
      * takes in:
          unit
      * returns unit and the counter is reset
*)
let (fresh, reset) =
    let nxt = ref 0 in
    let f () = (nxt := !nxt + 1; string_of_int (!nxt)) in
    let r () = nxt := 0 in
    (f, r)

(*
   find_vars:
     * takes in:
         q - a list of exp
     * returns a list of all VarExp in the list
*)
let rec find_vars q  =
    match q with
    | [] -> []
    | (x :: xs) -> (
        match x with
        | VarExp v -> x :: (find_vars xs)
        | ConstExp c -> (find_vars xs)
        | TermExp (s, el) -> (find_vars el) @ (find_vars xs)
    )


(*
   find_vars_string:
     * takes in:
         q - a list of exp
     * returns a list of all VarExp as strings
*)
let rec find_vars_string q  =
    match q with
    | [] -> []
    | (x :: xs) -> (
        match x with
        | VarExp v -> v :: (find_vars_string xs)
        | ConstExp c -> (find_vars_string xs)
        | TermExp (s, el) -> (find_vars_string el) @ (find_vars_string xs)
    )

(*
   uniq:
     * takes in:
         l - a list
     * returns the list reversed with only one copy of each element
  adapted from https://rosettacode.org/wiki/Remove_duplicate_elements#OCaml
*)
let uniq l =
    let rec tail_uniq a l =
        match l with
        | [] -> a
        | hd :: tl ->
            tail_uniq (hd :: a) (List.filter (fun x -> (x <> hd) ) tl) in
            tail_uniq [] l

(*
   sub_lift_goal:
     * takes in:
         sub - a list of substitutions for variables
         g - a goal of type exp
     * returns the goal with the substitutions applied
*)
let rec sub_lift_goal sub g =
    match g with
    | VarExp v -> (
        (* if this variable has a substitution do the substitution *)
        try let i = List.assoc g sub in i
        with Not_found -> VarExp v
    )
    | TermExp (s, el) ->
        TermExp (s, List.map (fun g1 -> sub_lift_goal sub g1) el)
    | _  -> g

(*
   sub_lift_goal:
     * takes in:
         sub - a list of substitutions for variables
         gl - a list of goals each of type exp
     * returns the list of goals with the substitutions applied to each goal
*)
let sub_lift_goals sub gl =
    List.map (fun g1 -> sub_lift_goal sub g1) gl

(*
   rename_vars_in_dec:
     * takes in:
         d - a dec type
     * returns a dec with all the variables in d renamed to fresh variable names
*)
let rec rename_vars_in_dec d =
    match d with
    | Clause (h, b) ->
        let head_vars = find_vars [h] in
        let body_vars = find_vars b in
        (* find uniq vars from both head and body *)
        let vars = uniq (head_vars @ body_vars) in
        (* get fresh variable mappings *)
        let sub = List.map (fun x -> (x, VarExp (fresh()))) vars in
        (* substitute new names for variables *)
        Clause (sub_lift_goal sub h, sub_lift_goals sub b)
    | Query (b) ->
        (* find uniq vars in query *)
        let body_vars = find_vars b in
        (* get fresh variable mappings *)
        let vars = uniq (body_vars) in
        let sub = List.map (fun x -> (x, VarExp (fresh()))) vars in
        (* substitute new names for variables *)
        Query (sub_lift_goals sub b)

(*
   pairandcat:
     * takes in:
         sargs - a list of exps
         targs - a list of exps
         c - a list of constraints where each constraint is of type (exp * exp)
     * returns a new list of constraints where c is prepended with each entry
       from sargs is paired with a corresponding entry from targs
       to make a new constraint
     * used for implementing decompose for unification
     * sargs and targs must be the same length, otherwise an exception is thrown
*)
let rec pairandcat sargs targs c =
    match sargs with
    | [] -> (
        if (List.length targs = 0)
        then c
        else raise (Failure "sargs and targs should be the same length")
    )
    | (s :: ss) -> (
        match targs with
        | (t :: ts) -> pairandcat ss ts ((s, t) :: c)
        |  _ -> raise (Failure "sargs and targs should be the same length")
    )

(*
   replace:
     * takes in:
         c - a list of constraints where each constraint is of type (exp * exp)
         sub - a list of substitutions
     * returns a new list of constraints where the substitutions are applied to
       both sides of each constraint
*)
let rec replace c sub =
    match c with
    | [] -> []
    | ((s, t) :: xs) ->
        (sub_lift_goal sub s, sub_lift_goal sub t) :: (replace xs sub)

(*
   occurs:
     * takes in:
         n - a string
         t - an exp
     * returns true if n matches any variable names in t and false otherwise
*)
let rec occurs n t =
     match t with
     | VarExp m -> n = m
     | TermExp (st, el) ->
        List.fold_left (fun acc v -> acc || (occurs n v)) false el
     | _ -> false

(*
   unify:
     * takes in:
         constraints - a list of constraints where each constraint
         is of type (exp * exp)
     * returns None if the constraints can't be unified,
       otherwise returns Some(i) where i is a list of substitutions
       that unify the constraints
*)
let rec unify constraints =
    match constraints with
    | [] -> Some []
    | ((s, t) :: c') ->
        if s = t
        then unify c'  (* Delete *)
        else (
            match s with
            | VarExp(n) ->
                (* Eliminate *)
                if (occurs n t)
                then None
                else let sub = [(s,t)] in
                     let c'' = replace c' sub in
                     let phi = unify c'' in (
                        match phi with
                        | None -> None
                        | Some l -> Some ((s, sub_lift_goal l t) :: l)
                     )
            | TermExp (sname, sargs) -> (
                match t with
                (* Orient *)
                | VarExp k -> unify ((t, s) :: c')
                (* Decompose *)
                | TermExp (tname, targs) ->
                    if (tname = sname && List.length targs = List.length sargs)
                    then unify (pairandcat sargs targs c')
                    else None
                | _ -> None
            )
            | _ -> (
                match t with
                (* Orient *)
                | VarExp k -> unify ((t, s) :: c')
                | _ -> None
            )
        )

(*
   eval_query:
     * takes in (all in a triple):
         q - a list of exp
         db - a list of dec
         env - a list of substitutions
               where each substitution is of type (exp * exp)
     * returns a list of lists of substitutions where each
       substitution is of type (exp * exp)
         - if the returned list is empty then no solutions were found for the
           query for the given db
         - otherwise, each element is a list of substitutions for one solution
           to the query with the given db
*)
let rec eval_query (q, db, env) orig_vars =
    match q with
    | [] -> (
        (* no more subgoals to prove so finished *)
        [env]
    )
    | (g1 :: gl) -> (  (* have at least one more subgoal (g1) to prove *)
        let vars_list_string = (find_vars_string q)@orig_vars |> uniq in
        let env =
            List.filter (fun (v, _) ->
                match v with
                | VarExp elt -> List.exists (fun a -> String.equal elt a) vars_list_string
                | _ -> false
            )
            env
        in 
        match g1 with
        (* if goal is the true predicate *)
        | TermExp("true", []) -> (
          eval_query (
              gl,
              db,
              env
            )
            orig_vars
        )
        (* if goal is some other predicate *)
        | TermExp(_,_) -> (
        (* iterate over the db *)
        List.fold_right (
            fun rule r -> (
                match (rename_vars_in_dec rule) with (* rename vars in rule *)
                | Clause (h, b) -> (
                    (* check if this rule can be used for this subgoal *)
                    match unify [(g1, h)] with
                    | Some s -> (
                        match unify (s@env) with
                        | Some env2 -> (
                            if (List.length b = 1)
                            then (
                                match b with
                                (* if the rule proved the subgoal (ie. rule was a
                                   fact) then recurse on remaining subgoals *)
                                | ((TermExp ("true", _)) :: ys) ->
                                    ((eval_query (
                                        sub_lift_goals s gl,
                                        db,
                                        env2
                                     ) orig_vars
                                     ) @ r)
                                (* if rule wasn't a fact then we have more
                                   subgoals from the body of the rule
                                   to prove *)
                                | _ -> ((eval_query (
                                    (sub_lift_goals s b) @ (sub_lift_goals s gl),
                                    db,
                                    env2
                                    ) orig_vars
                                ) @ r))
                            else
                                (* if rule wasn't a fact then we have more
                                   subgoals from the body of the rule
                                   to prove *)
                                ((eval_query (
                                    (sub_lift_goals s b) @ (sub_lift_goals s gl),
                                    db,
                                    env2
                                    ) orig_vars
                                ) @ r)
                        )
                        (* the substitution from unify the rule head and subgoal
                           doesn't unify with the environment gathered so far *)
                        | _ -> r
                    )
                    (* this rule's head doesn't unify with the subgoal *)
                    | _ -> r
                )
                (* found a dec in the db that isn't a Clause *)
                |  _ -> r
          )) db [] )
        (* subgoal isn't a TermExp *)
        | _ -> eval_query (gl, db, env) orig_vars
    )

(*
   string_of_res:
     * takes in:
         e - a list of lists of substitutions where each
             substitution is of type (exp * exp)
         orig_query_vars - a list of uniq VarExps that appeared
                           in the original query
         orig_vars_num - number of uniq VarExps that appeared
                         in the original query
     * returns a string consisting of all substitutions of variables
       appearing in the original query of all solutions found and the
       word true if solution(s) were found and false otherwise
*)
let string_of_res e orig_query_vars orig_vars_num =
   (* iterate over e for each solution *)
   List.fold_left (
        fun r2 env ->
        if orig_vars_num > 0
        then
          "====================\n" ^
            (* iterate over original query vars to find their substitution *)
            (List.fold_left (
                 fun r d -> (
                   match d with
                   | VarExp v -> (
                     (* find variable substitution in the solution *)
                     try let f = List.assoc (VarExp v) env in (
                             match f with
                             | VarExp v2 ->
                                (v ^ " is free\n") ^ r
                             | _ ->
                                (v ^ " = " ^ (
                                   readable_string_of_exp f) ^ "\n") ^ r
                           )
                     with Not_found -> (v ^ " is free\n") ^ r)
                   | _ -> r
                 )
               ) "" (orig_query_vars) ) ^
              "====================\n"  ^ r2
        else "" ^ r2
     )  (if List.length e > 0 (* if e is empty then there were no solutions *)
         then "true\n"
         else "false\n")
                  e

(*
   add_dec_to_db:
     * takes in (all in a tuple):
         dec - a dec type
         db - a list of dec types
     * returns db prepended with dec if dec is not
       of the pattern TermExp("true",_) as we don't want users to be able
       to redefine the "true" atom
       otherwise, db is returned
*)
let add_dec_to_db (dec, db) =
    match dec with
    | Clause (h, b) -> (
        match h with
        (* don't allow user to add a new definition of true *)
        | TermExp ("true", _) ->
            print_string "Can't reassign true predicate\n"; db
        | _ -> dec :: db
    )
    | Query (b) -> (
        dec :: db
    )

(*
   eval_dec:
     * takes in (all in a tuple):
         dec - a dec type
         db - a list of dec types
     * evaluated the dec with the given db
       returns the original db in the case
       dec is a Query type
       otherwise returns db prepended with dec
*)
let eval_dec (dec, db) =
    match dec with
    | Clause (h, b) -> add_dec_to_db (dec, db)
    | Query b -> (
        (* find all uniq VarExps in query *)
        let orig_vars = uniq (find_vars b) in
        let orig_vars_string = find_vars_string b |> uniq in
        (* find num of VarExps in query *)
        let orig_vars_num = List.length orig_vars in
        (* evaluate query *)
        let res = eval_query (b, db, []) orig_vars_string in
        (* print the result *)
        print_string (string_of_res (res) orig_vars orig_vars_num);
        (* reset fresh variable counter *)
        reset ();
        db
    )
