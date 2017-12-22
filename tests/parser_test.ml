open OUnit2
open Common
open Main


let parser_test_suite =
    "Parser" >::: (
        List.map (
            fun (arg, res) ->
                let title =
                    arg
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal res (parse arg)
                )
        )
        [
            (* Facts *)
            "cat.", (
                Clause (TermExp ("cat", []), ConstExp (BoolConst true))
            );
            "cat().", (
                Clause (TermExp ("cat", []), ConstExp (BoolConst true))
            );
            "cat(tom).", (
                Clause (TermExp ("cat", [TermExp ("tom", [])]), ConstExp (BoolConst true))
            );
            "cat(X).", (
                Clause (TermExp ("cat", [VarExp "X"]), ConstExp (BoolConst true))
            );
            "coord(X, Y, Z).", (
                Clause (
                    TermExp ("coord", [VarExp "X"; VarExp "Y"; VarExp "Z"]),
                    ConstExp (BoolConst true)
                )
            );

            (* Rules *)
            "animal(X) :- cat(X).", (
                Clause (TermExp ("animal", [VarExp "X"]), TermExp ("cat", [VarExp "X"]))
            );
            "sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).", (
                Clause (
                    TermExp ("sibling", [VarExp "X"; VarExp "Y"]),
                    ConjunctionExp (
                        TermExp ("parent_child", [VarExp "Z"; VarExp "X"]),
                        TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])
                    )
                )
            );
            "sibling(X, Y) :- parent_child(Z, X); parent_child(Z, Y).", (
                Clause (
                    TermExp ("sibling", [VarExp "X"; VarExp "Y"]),
                    DisjunctionExp (
                        TermExp ("parent_child", [VarExp "Z"; VarExp "X"]),
                        TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])
                    )
                )
            );

            (* Queries *)
            "?- cat(tom).", (
                Query (TermExp ("cat", [TermExp ("tom", [])]))
            );
            "?- cat(X).", (
                Query (TermExp ("cat", [VarExp "X"]))
            );
            "?- sibling(sally, erica).", (
                Query (TermExp ("sibling", [TermExp ("sally", []); TermExp ("erica", [])]))
            );
        ]
    )
