open OUnit2
open Ast
open Common
open Evaluator


let identity_func s = s
let turn_to_unit x = ()

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
                        ~printer:identity_func
                        res arg
                )
        )
        [
            (* Fresh variables *)
            (turn_to_unit (reset());
             turn_to_unit (fresh());
             fresh()
            ), "2";

            (turn_to_unit (fresh());
             turn_to_unit (fresh());
             turn_to_unit (reset());
             fresh()
            ), "1";

            (* Finding variables in declarations *)
            (string_of_exp_list
                (find_vars
                    ([VarExp "X"; ConstExp(IntConst 10); TermExp("blah",[])])
                )
            ), "[VarExp \"X\"]";

            (string_of_exp_list
                (find_vars
                    ([VarExp "X"; ConstExp(IntConst 10); TermExp("blah",[VarExp "X"; VarExp "Y"])])
                )
            ), "[VarExp \"X\"; VarExp \"X\"; VarExp \"Y\"]";

            (* Finding unique members (in this case variables) in a list *)
            (string_of_exp_list
                (uniq
                    ([VarExp "X"; VarExp "X"; VarExp "Y"])
                )
            ), "[VarExp \"Y\"; VarExp \"X\"]";

            (* Lifting a goal with a substituion *)
            (string_of_exp
                (sub_lift_goal
                    ([(VarExp "X", VarExp "1")])
                    (VarExp "X")
                )
            ), "VarExp \"1\"";

            (string_of_exp
                (sub_lift_goal
                    ([(VarExp "X", VarExp "1")])
                    (VarExp "Y")
                )
            ), "VarExp \"Y\"";

            (string_of_exp
                (sub_lift_goal
                    ([(VarExp "X", VarExp "1")])
                    (ConstExp(IntConst 10))
                )
            ), "ConstExp (IntConst 10)";

            (* Lifting goals with a substitution *)
            (string_of_exp_list
                (sub_lift_goals
                    ([(VarExp "X", VarExp "1")])
                    ([VarExp("X"); ConstExp(IntConst 10); TermExp("blah", [VarExp "X"; VarExp "Y"; ConstExp (IntConst 1)])])
                )
            ), "[VarExp \"1\"; ConstExp (IntConst 10); TermExp (\"blah\", [VarExp \"1\"; VarExp \"Y\"; ConstExp (IntConst 1)])]";

            (string_of_exp_list
                (sub_lift_goals
                    ([])
                    ([VarExp("X"); ConstExp(IntConst 10); TermExp("blah", [VarExp "X"; VarExp "Y"; ConstExp (IntConst 1)])])
                )
            ), "[VarExp \"X\"; ConstExp (IntConst 10); TermExp (\"blah\", [VarExp \"X\"; VarExp \"Y\"; ConstExp (IntConst 1)])]";

            (string_of_exp_list
                (sub_lift_goals
                    ([(VarExp "X", VarExp "1"); (VarExp "Z", VarExp "blu")])
                    ([VarExp("X"); ConstExp(IntConst 10); TermExp("blah", [VarExp "X"; VarExp "Y"; ConstExp (IntConst 1)])])
                )
            ), "[VarExp \"1\"; ConstExp (IntConst 10); TermExp (\"blah\", [VarExp \"1\"; VarExp \"Y\"; ConstExp (IntConst 1)])]";

            (* Renaming variables in a declaration*)
            (string_of_dec
                (rename_vars_in_dec
                    (Clause(TermExp("age",[TermExp("zaid",[]);ConstExp(IntConst 10) ]), [(ConstExp (IntConst 1))]))
                )
            ), "Clause (TermExp (\"age\", [TermExp (\"zaid\", []); ConstExp (IntConst 10)]), [ConstExp (IntConst 1)])";

            (turn_to_unit (reset());
             string_of_dec
                (rename_vars_in_dec
                    (Clause (TermExp ("sibling", [VarExp "X"; VarExp "Y"]), [TermExp ("parent_child", [VarExp "Z"; VarExp "X"]); TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])]))
                )
            ), "Clause (TermExp (\"sibling\", [VarExp \"3\"; VarExp \"2\"]), [TermExp (\"parent_child\", [VarExp \"1\"; VarExp \"3\"]); TermExp (\"parent_child\", [VarExp \"1\"; VarExp \"2\"])])";

            (string_of_dec
                (rename_vars_in_dec
                    (Query ([TermExp ("age", [TermExp ("zaid", [])])]))
                )
            ), "Query ([TermExp (\"age\", [TermExp (\"zaid\", [])])])";

            (turn_to_unit (reset());
             string_of_dec
                (rename_vars_in_dec
                    (Query ([TermExp ("parent", [VarExp "X"; VarExp "Y"]); TermExp ("male", [VarExp "X"])]))
                )
            ), "Query ([TermExp (\"parent\", [VarExp \"2\"; VarExp \"1\"]); TermExp (\"male\", [VarExp \"2\"])])";

            (* Pairandcat function for handling decompose case of unification *)
            (string_of_subs
                (pairandcat
                    ([TermExp ("trude", []); TermExp ("sally", [])])
                    ([VarExp "X"; VarExp "Y"])
                    ([])
                )
            ), "[(TermExp (\"sally\", []), VarExp \"Y\"); (TermExp (\"trude\", []), VarExp \"X\")]";

            (string_of_subs
                (pairandcat
                    ([])
                    ([])
                    ([(VarExp "Z", ConstExp(IntConst 10))])
                )
            ), "[(VarExp \"Z\", ConstExp (IntConst 10))]";

            (string_of_subs
                (pairandcat
                    ([TermExp ("trude", []); TermExp ("sally", [])])
                    ([VarExp "X"; VarExp "Y"])
                    ([(VarExp "Z", ConstExp(IntConst 10))])
                )
            ), "[(TermExp (\"sally\", []), VarExp \"Y\"); (TermExp (\"trude\", []), VarExp \"X\"); (VarExp \"Z\", ConstExp (IntConst 10))]";

            (try
                string_of_subs
                    (pairandcat
                        ([VarExp "X"; VarExp "Y"])
                        ([])
                        ([(VarExp "Z", ConstExp(IntConst 10))])
                    )
             with Failure s -> s
            ), "sargs and targs should be the same length";

            (try
                string_of_subs
                    (pairandcat
                        ([])
                        ([VarExp "X"; VarExp "Y"])
                        ([(VarExp "Z", ConstExp(IntConst 10))])
                    )
             with Failure s -> s
            ), "sargs and targs should be the same length";

            (* replace function for the elimination case of unification *)
            (string_of_subs
                (replace
                    ([(VarExp "Z", ConstExp(IntConst 10))])
                    ([])
                )
            ), "[(VarExp \"Z\", ConstExp (IntConst 10))]";

            (string_of_subs
                (replace
                    ([(VarExp "Z", ConstExp(IntConst 10))])
                    ([(VarExp "X", VarExp "1")])
                )
            ), "[(VarExp \"Z\", ConstExp (IntConst 10))]";

            (string_of_subs
                (replace
                    ([(VarExp "Z", ConstExp(IntConst 10))])
                    ([(VarExp "Z", VarExp "1")])
                )
            ), "[(VarExp \"1\", ConstExp (IntConst 10))]";

            (string_of_subs
                (replace
                    ([])
                    ([(VarExp "X", VarExp "1")])
                )
            ), "[]";

            (string_of_subs
                (replace
                    ([])
                    ([])
                )
            ), "[]";

            (string_of_subs
                (replace
                    ([(VarExp "Z", ConstExp(IntConst 10)); (VarExp "X", TermExp("blah", [VarExp "X"; VarExp "Z"]))])
                    ([(VarExp "Z", VarExp "1"); (VarExp "X", TermExp("and",[]))])
                )
            ), "[(VarExp \"1\", ConstExp (IntConst 10)); (TermExp (\"and\", []), TermExp (\"blah\", [TermExp (\"and\", []); VarExp \"1\"]))]";

            (* occurs function for elimination case of unification *)
            (string_of_bool
                (occurs
                    ("1")
                    (ConstExp(StringConst "name"))
                )
            ), "false";

            (string_of_bool
                (occurs
                    ("1")
                    (VarExp "X")
                )
            ), "false";

            (string_of_bool
                (occurs
                    ("1")
                    (VarExp "1")
                )
            ), "true";

            (string_of_bool
                (occurs
                    ("1")
                    (TermExp ("1",[VarExp"10"; TermExp("blah", []); ConstExp(IntConst 1)]))
                )
            ), "false";

            (string_of_bool
                (occurs
                    ("1")
                    (TermExp ("1",[VarExp"1"; TermExp("blah", []); ConstExp(IntConst 1)]))
                )
            ), "true";

            (string_of_bool
                (occurs
                    ("1")
                    (TermExp ("1",[VarExp"10"; TermExp("blah", [VarExp "1"]); ConstExp(IntConst 1)]))
                )
            ), "true";

            (* Unification *)
            (string_of_unify_res
                (unify
                    ([])
                )
            ), "[]";

            (string_of_unify_res
                (unify
                    ([(VarExp "X", VarExp "X")])
                )
            ), "[]";

            (string_of_unify_res
                (unify
                    ([(ConstExp (IntConst 10), ConstExp (IntConst 10))])
                )
             ), "[]";

            (string_of_unify_res
                (unify
                    ([(VarExp "X", TermExp("blah", [VarExp "X"]))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(VarExp "X", TermExp("blah", [TermExp("and", [])]))])
                )
            ), "[(VarExp \"X\", TermExp (\"blah\", [TermExp (\"and\", [])]))]";

            (string_of_unify_res
                (unify
                    ([(VarExp "X", TermExp("blah", [TermExp("and", [])])); (VarExp "Z", TermExp("blah", [VarExp "X"; VarExp "Z"]))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(VarExp "X", TermExp("blah", [TermExp("and", [])])); (VarExp "Z", TermExp("blah", [VarExp "X"]))])
                )
            ), "[(VarExp \"X\", TermExp (\"blah\", [TermExp (\"and\", [])])); (VarExp \"Z\", TermExp (\"blah\", [TermExp (\"blah\", [TermExp (\"and\", [])])]))]";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [TermExp("and", [])]), VarExp "X")])
                )
            ), "[(VarExp \"X\", TermExp (\"blah\", [TermExp (\"and\", [])]))]";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [VarExp "X"]), TermExp("hah", []))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [VarExp "X"]), TermExp("hah", [VarExp "Z"]))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [VarExp "X"]), TermExp("blah", []))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [ConstExp(IntConst 10)]), TermExp("blah", [VarExp "X"]))])
                )
            ), "[(VarExp \"X\", ConstExp (IntConst 10))]";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [TermExp("hah", [])]), TermExp("blah", [VarExp "X"]))])
                )
            ), "[(VarExp \"X\", TermExp (\"hah\", []))]";

            (string_of_unify_res
                (unify
                    ([(TermExp("blah", [VarExp "X"]), ConstExp(IntConst 10))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(ConstExp (IntConst 10), TermExp("blah", []))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(ConstExp (IntConst 10), VarExp "X")])
                )
            ), "[(VarExp \"X\", ConstExp (IntConst 10))]";

            (string_of_unify_res
                (unify
                    ([(ConstExp (IntConst 10), ConstExp (IntConst 100))])
                )
            ), "None";

            (string_of_unify_res
                (unify
                    ([(TermExp("sibling", [VarExp "1"; VarExp "2"]), TermExp("sibling", [VarExp "X"; VarExp "Y"]))])
                )
            ), "[(VarExp \"2\", VarExp \"Y\"); (VarExp \"1\", VarExp \"X\")]";

            (* Evaluating results of a query with a given db *)
            (string_of_res
                (eval_query
                    (
                        [],
                        [],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("true", [])],
                        [],
                        []
                    )
                )
                []
                0
            ), "true\n";


            (string_of_res
                (eval_query
                    (
                        [TermExp ("male", [TermExp ("elizabeth", [])])],
                        [],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("parent", [VarExp "X"; TermExp ("charles1", [])])],
                        [],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("male", [TermExp ("elizabeth", [])])],
                        [Clause (TermExp("female", [TermExp("elizabeth", [TermExp ("true", [])])]), [])],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("male", [TermExp ("elizabeth", [])])],
                        [Clause (TermExp("elizabeth", [TermExp("male", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("female", [TermExp ("elizabeth", [])])],
                        [Clause (TermExp("female", [TermExp("elizabeth", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("female", [TermExp ("elizabeth", [])])],
                        [Clause (TermExp("female", [TermExp("elizabeth", [])]), [TermExp("true", [])])],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("female", [TermExp ("elizabeth", [])])],
                        [Clause (TermExp("female", [TermExp("elizabeth", [])]), [TermExp("true", [])])],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("male", [TermExp ("elizabeth", [])])],
                        [Query([TermExp ("male", [TermExp ("elizabeth", [])])]); Clause (TermExp("female", [TermExp("elizabeth", [])]), [TermExp("true", [])])],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [TermExp("zaid",[]); VarExp "Y"])],
                        [],
                        []
                    )
                )
                [VarExp "Y"]
                1
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [TermExp("zaid",[]); VarExp "Y"])],
                        [Clause (TermExp ("age", [ConstExp (StringConst "adam"); ConstExp (IntConst 10)]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Y"]
                1
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [TermExp("zaid",[]); VarExp "Y"])],
                        [Clause (TermExp ("age", [ConstExp (StringConst "adam"); ConstExp (IntConst 10)]), [TermExp ("true", [])]);Clause (TermExp ("age", [TermExp ("zaid", []); ConstExp (IntConst 5)]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Y"]
                1
            ), "====================\nY = 5\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [VarExp "E"; VarExp "Z"])],
                        [Clause (TermExp ("age", [ConstExp (StringConst "adam"); ConstExp (IntConst 10)]), [TermExp ("true", [])]);Clause (TermExp ("age", [TermExp ("zaid", []); ConstExp (IntConst 5)]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Z"; VarExp "E"]
                2
            ), "====================\nE = zaid\nZ = 5\n====================\n====================\nE = \"adam\"\nZ = 10\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [VarExp "X"; ConstExp (IntConst 5)])],
                        [Clause (TermExp ("age", [ConstExp (StringConst "adam"); ConstExp (IntConst 10)]), [TermExp ("true", [])]);Clause (TermExp ("age", [TermExp ("zaid", []); ConstExp (IntConst 5)]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "X"]
                1
            ), "====================\nX = zaid\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp ("a", [])],
                        [Clause (TermExp ("a", []), [TermExp ("true", [])])],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("age", [VarExp "X"; VarExp "Y"]); TermExp("female", [VarExp "X"])],
                        [Clause (TermExp ("age", [ConstExp (StringConst "adam"); ConstExp (IntConst 10)]), [TermExp ("true", [])]);Clause (TermExp ("age", [TermExp ("zaid", []); ConstExp (IntConst 5)]), [TermExp ("true", [])]); Clause (TermExp ("age", [TermExp ("ann", []); ConstExp (IntConst 12)]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("zaid", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [ConstExp (StringConst "adam")]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("ann",[])]),[TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Y"; VarExp "X"]
                2
            ), "====================\nX = ann\nY = 12\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("sibling", [TermExp("sally",[]); TermExp("erica",[])])],
                        [Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("mother_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("father_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("sibling", [VarExp "X"; VarExp "Y"]), [TermExp ("parent_child", [VarExp "Z"; VarExp "X"]); TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])]); Clause (TermExp ("father_child", [TermExp ("mike", []); TermExp ("tom", [])]), [TermExp ("true", [])]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("erica", [])]), [TermExp ("true", [])]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("sally", [])]), [TermExp ("true", [])]); Clause (TermExp ("mother_child", [TermExp ("trude", []); TermExp ("sally", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                []
                0
            ), "true\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("sibling", [VarExp "Z"; VarExp "E"])],
                        [Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("mother_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("parent_child", [VarExp "X"; VarExp "Y"]), [TermExp ("father_child", [VarExp "X"; VarExp "Y"])]); Clause (TermExp ("sibling", [VarExp "X"; VarExp "Y"]), [TermExp ("parent_child", [VarExp "Z"; VarExp "X"]); TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])]); Clause (TermExp ("father_child", [TermExp ("mike", []); TermExp ("tom", [])]), [TermExp ("true", [])]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("erica", [])]), [TermExp ("true", [])]); Clause (TermExp ("father_child", [TermExp ("tom", []); TermExp ("sally", [])]), [TermExp ("true", [])]); Clause (TermExp ("mother_child", [TermExp ("trude", []); TermExp ("sally", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "E"; VarExp "Z"]
                2
            ), "====================\nZ = sally\nE = sally\n====================\n====================\nZ = sally\nE = erica\n====================\n====================\nZ = erica\nE = sally\n====================\n====================\nZ = erica\nE = erica\n====================\n====================\nZ = tom\nE = tom\n====================\n====================\nZ = sally\nE = sally\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("animal", [VarExp "X"; VarExp "Y"])],
                        [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Y"; VarExp "X"]
                2
            ), "====================\nX = tom\nY is free\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("animal", [VarExp "X"; VarExp "Y"]); VarExp "Z"],
                        [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Z"; VarExp "Y"; VarExp "X"]
                3
            ), "====================\nX = tom\nY is free\nZ is free\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [VarExp "X"],
                        [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "X"]
                1
            ), "====================\nX is free\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("animal", [VarExp "X"; VarExp "Y"]); VarExp "Z"],
                        [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])])],
                        []
                    )
                )
                [VarExp "Z"; VarExp "Y"; VarExp "X"; ConstExp(IntConst 10); TermExp("blah", [])]
                3
            ), "====================\nX = tom\nY is free\nZ is free\n====================\ntrue\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("animal", [VarExp "X"; VarExp "Y"]); VarExp "Z"],
                        [Clause (TermExp ("animal", [VarExp "X"; VarExp "Y"]), [TermExp ("cat", [VarExp "X"])]); Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])])],
                        [(VarExp "X", TermExp("eh",[VarExp "X"]))]
                    )
                )
                [VarExp "Z"; VarExp "Y"; VarExp "X"; ConstExp(IntConst 10); TermExp("blah", [])]
                3
            ), "false\n";

            (string_of_res
                (eval_query
                    (
                        [TermExp("b", [TermExp("a", [TermExp("true",[])])])],
                        [Clause (TermExp("b",[VarExp "X"]), [TermExp("a", [VarExp "X"])]); Clause (TermExp("a",[TermExp("true",[])]), [TermExp ("true", [])])],
                        []
                    )
                )
                []
                0
            ), "false\n";

            (* Adding declarations to db *)
            (string_of_db
                (add_dec_to_db
                    (
                        Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])]),
                        []
                    )
                )
            ), "[Clause (TermExp (\"cat\", [TermExp (\"tom\", [])]), [TermExp (\"true\", [])])]";

            (string_of_db
                (add_dec_to_db
                    (
                        Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])]),
                        []
                    )
                )
            ), "[Clause (TermExp (\"cat\", [TermExp (\"tom\", [])]), [TermExp (\"true\", [])])]";

            (string_of_db
                (add_dec_to_db
                    (
                        Clause (TermExp ("true", []), [TermExp ("true", [])]),
                        []
                    )
                )
            ), "[]";

            (string_of_db
                (add_dec_to_db
                    (
                        Clause (TermExp ("true", [TermExp ("blah",[])]), [TermExp ("true", [])]),
                        []
                    )
                )
            ), "[]";

            (string_of_db
                (add_dec_to_db
                    (
                        Query ([TermExp ("parent", [VarExp "X"; TermExp ("charles1", [])]); TermExp ("male", [VarExp "X"])]),
                        []
                    )
                )
            ), "[Query ([TermExp (\"parent\", [VarExp \"X\"; TermExp (\"charles1\", [])]); TermExp (\"male\", [VarExp \"X\"])])]";

            (* Evaluating a declaration *)
            (string_of_db
                (eval_dec
                    (
                        Clause (TermExp ("cat", [TermExp ("tom", [])]), [TermExp ("true", [])]),
                        []
                    )
                )
            ), "[Clause (TermExp (\"cat\", [TermExp (\"tom\", [])]), [TermExp (\"true\", [])])]";

            (string_of_db
                (eval_dec
                    (
                        Query ([TermExp ("male", [TermExp ("charles1", [])])]),
                        [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("george1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james1", [])]), [TermExp ("true", [])])]
                    )
                )
            ), "[Clause (TermExp (\"parent\", [TermExp (\"george1\", []); TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"sophia\", []); TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"james2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"catherine\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"elizabeth\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles1\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"catherine\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"george1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james1\", [])]), [TermExp (\"true\", [])])]";

            (string_of_db
                (eval_dec
                    (
                        Query ([TermExp ("male", [TermExp ("charles1", [])]);TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1",[] )])]),
                        [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("george1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james1", [])]), [TermExp ("true", [])])]
                    )
                )
            ), "[Clause (TermExp (\"parent\", [TermExp (\"george1\", []); TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"sophia\", []); TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"james2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"catherine\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"elizabeth\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles1\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"catherine\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"george1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james1\", [])]), [TermExp (\"true\", [])])]";

            (string_of_db
                (eval_dec
                    (
                        Query ([TermExp ("parent", [VarExp "X"; TermExp ("charles1", [])]); TermExp ("male", [VarExp "X"])]),
                        [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("george1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("true", []), [TermExp ("true", [])])]
                    )
                )
            ), "[Clause (TermExp (\"parent\", [TermExp (\"george1\", []); TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"sophia\", []); TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"james2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"catherine\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"elizabeth\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles1\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"catherine\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"george1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"true\", []), [TermExp (\"true\", [])])]";

            (string_of_db
                (eval_dec
                    (
                        Query ([TermExp ("parent", [VarExp "X"; TermExp ("charles1", [])]); TermExp ("female", [VarExp "X"])]),
                        [Clause (TermExp ("parent", [TermExp ("george1", []); TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("sophia", []); TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("james2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("catherine", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles2", []); TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("elizabeth", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("parent", [TermExp ("charles1", []); TermExp ("james1", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("sophia", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("elizabeth", [])]), [TermExp ("true", [])]); Clause (TermExp ("female", [TermExp ("catherine", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("george1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles2", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("charles1", [])]), [TermExp ("true", [])]); Clause (TermExp ("male", [TermExp ("james1", [])]), [TermExp ("true", [])])]
                    )
                )
            ), "[Clause (TermExp (\"parent\", [TermExp (\"george1\", []); TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"sophia\", []); TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"james2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"catherine\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles2\", []); TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"elizabeth\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"parent\", [TermExp (\"charles1\", []); TermExp (\"james1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"sophia\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"elizabeth\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"female\", [TermExp (\"catherine\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"george1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles2\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"charles1\", [])]), [TermExp (\"true\", [])]); Clause (TermExp (\"male\", [TermExp (\"james1\", [])]), [TermExp (\"true\", [])])]";
        ]
    )
