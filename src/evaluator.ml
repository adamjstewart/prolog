open Ast

let rec check_if_dec_in_db (Clause(h,b) ,db) = match db with [] -> false
                                                           | ((Clause(h1,b1))::xs) ->
                                                              if h = h1
                                                              then true
                                                              else check_if_dec_in_db (Clause(h,b) ,xs)
                                                             
let rec update_dec_in_db  (Clause(h,newb),db) = match db with [] -> []
                                                            | ((Clause(h1,b1))::xs) ->
                                                               if h = h1
                                                               then (Clause(h,newb))::xs
                                                               else (Clause(h1,b1))::(update_dec_in_db (Clause(h,newb),xs))
                                                                                    
let add_clause_to_db (dec,db) = match dec with Clause(h,b) -> let r = check_if_dec_in_db (dec,db) in
                                                             if r then update_dec_in_db (dec,db) else (Clause(h,b))::db

let eval_dec (dec, db) = match dec with Clause(h,b) -> (add_clause_to_db(dec, db), None)
                                      | Query(b) -> raise (Failure "Not Implementing right now")
