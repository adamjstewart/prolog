open Ast


let add_clause_to_db (dec,db) = match dec with Clause(h,b) -> ClauseRes((Clause(h,b))::db)

let eval_dec (dec, db) = match dec with Clause(h,b) -> add_clause_to_db(dec, db)
                                      | Query(b) -> raise (Failure "Not Implementing right now")
