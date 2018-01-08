open OUnit2
open Ast
open Common
open Evaluator


let string_of_string s = s

let evaluator_test_suite =
    "Evaluator" >::: (
        List.map (
            fun (arg, res) ->
                let title =
                    res
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal
                        ~printer:string_of_string
                        res arg
                )
        )
        [
          (print_string (string_of_db (eval_dec (
               Query ([TermExp ("parent", [VarExp "X"; TermExp ("charles1", [])]); TermExp ("male", [VarExp "X"])]),
          [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("george1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))
                              ); "eval_query"), "eval_query";
          
          (print_string (string_of_db (eval_dec (
           Clause (TermExp ("female", [TermExp ("elizabeth2", [])]), [ConstExp (BoolConst true)])  ,
           [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("george1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))
             ); "eval_clause"), "eval_clause";

          (print_string (string_of_db (eval_dec (
           Clause (TermExp ("true", [TermExp ("elizabeth2", [])]), [ConstExp (BoolConst true)])  ,
           [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("george1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))
             ); "eval_clause"), "eval_clause";

           (print_string (string_of_db (eval_dec (
              Query ([TermExp ("male", [TermExp ("elizabeth", [])])]),
          [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("george1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("male", [TermExp ("james1", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))
                               ); "eval_query"), "eval_query";
            (print_string (string_of_db (eval_dec (
             Query ([TermExp ("animal", [VarExp "Z"; VarExp "E"])]),
         [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))

                                ); "eval_query"), "eval_query";
             (print_string (string_of_db (eval_dec (
             Clause (TermExp ("a", []), [ConstExp (BoolConst true)]),
         [Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))


                                ); "eval_query"), "eval_query";
            (print_string (string_of_db (eval_dec (
            Query ([TermExp ("a", [])]),
        [Clause (TermExp ("a", []), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))


                                ); "eval_query"), "eval_query";

            (print_string (string_of_db (eval_dec (
           Query ([TermExp ("sibline", [VarExp "Z"; VarExp "E"])]),
        [Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("mother_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("father_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("sibling", [VarExp "X"; VarExp "Y"]), [TermExp ("parent_child", [VarExp "Z"; VarExp "X"]); TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])]); Clause (TermExp ("father_child", [TermExp ("mike", []); TermExp ("tom", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("erica", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("sally", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("mother_child", [TermExp ("trude", []); TermExp ("sally", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))



                                ); "eval_query"), "eval_query";
             (print_string (string_of_db (eval_dec (
           Query ([TermExp ("sibling", [VarExp "Z"; VarExp "E"])]),
        [Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("mother_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("father_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("sibling", [VarExp "X"; VarExp "Y"]), [TermExp ("parent_child", [VarExp "Z"; VarExp "X"]); TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])]); Clause (TermExp ("father_child", [TermExp ("mike", []); TermExp ("tom", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("erica", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("sally", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("mother_child", [TermExp ("trude", []); TermExp ("sally", [])]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))



                                 ); "eval_query"), "eval_query";

             (print_string (string_of_db (eval_dec (
           Query ([TermExp ("x", [ConstExp (FloatConst 3.12)])]),
       [Clause (TermExp ("x", [ConstExp (FloatConst 3.12)]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))




                                 ); "eval_query"), "eval_query";
             
             (print_string (string_of_db (eval_dec (
           Query ([TermExp ("x", [VarExp "X"])]),
       [Clause (TermExp ("x", [ConstExp (FloatConst 3.12)]), [ConstExp (BoolConst true)]); Clause (TermExp ("true", []), [ConstExp (BoolConst true)])]))




                                ); "eval_query"), "eval_query";
        ]
    )
