open OUnit2
open Ast
open Common


let parser_test_suite =
    "Parser" >::: (
        List.map (
            fun (arg, res) ->
                let title =
                    arg
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal
                        ~printer:string_of_dec
                        res (parse arg)
                )
        )
        [
            (* Facts *)
            "cat.", (
                Clause (TermExp ("cat", []), [TermExp ("true", [])])
            );
            "cat().", (
                Clause (TermExp ("cat", []), [TermExp ("true", [])])
            );
            "cat(tom).", (
                Clause (
                    TermExp (
                        "cat", [TermExp ("tom", [])]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "cat(tom()).", (
                Clause (
                    TermExp (
                        "cat", [TermExp ("tom", [])]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "cat(X).", (
                Clause (
                    TermExp (
                        "cat", [VarExp "X"]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "coord(X, Y, Z).", (
                Clause (
                    TermExp (
                        "coord", [
                            VarExp "X";
                            VarExp "Y";
                            VarExp "Z"
                        ]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "coord(1, 2, 3).", (
                Clause (
                    TermExp (
                        "coord", [
                            ConstExp (IntConst 1);
                            ConstExp (IntConst 2);
                            ConstExp (IntConst 3)
                        ]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "coord(1.0, 2.0, 3.0).", (
                Clause (
                    TermExp (
                        "coord", [
                            ConstExp (FloatConst 1.);
                            ConstExp (FloatConst 2.);
                            ConstExp (FloatConst 3.)
                        ]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
            "cousins(\"jack\", \"jill\").", (
                Clause (
                    TermExp (
                        "cousins", [
                            ConstExp (StringConst "jack");
                            ConstExp (StringConst "jill")
                        ]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );

            (* Rules *)
            "cat :- true.", (
                Clause (TermExp ("cat", []), [TermExp ("true", [])])
            );
            "animal(X) :- cat(X).", (
                Clause (
                    TermExp (
                        "animal", [VarExp "X"]
                    ), [
                        TermExp ("cat", [VarExp "X"])
                    ]
                )
            );
            "sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).", (
                Clause (
                    TermExp (
                        "sibling", [VarExp "X"; VarExp "Y"]
                    ), [
                        TermExp (
                            "parent_child", [VarExp "Z"; VarExp "X"]
                        );
                        TermExp (
                            "parent_child", [VarExp "Z"; VarExp "Y"]
                        )
                    ]
                )
            );
            "nonsense_words :- foo, bar, baz.", (
                Clause (
                    TermExp (
                        "nonsense_words", []
                    ), [
                        TermExp (
                            "foo", []
                        );
                        TermExp (
                            "bar", []
                        );
                        TermExp (
                            "baz", []
                        )
                    ]
                )
            );

            (* Queries *)
            "?- cat(tom).", (
                Query ([TermExp ("cat", [TermExp ("tom", [])])])
            );
            "?- cat(X).", (
                Query ([TermExp ("cat", [VarExp "X"])])
            );
            "?- sibling(sally, erica).", (
                Query ([
                    TermExp (
                        "sibling", [
                            TermExp ("sally", []);
                            TermExp ("erica", [])
                        ]
                    )
                ])
            );
            "?- sibling(sally, erica), sibling(john, joe).", (
                Query ([
                   TermExp (
                       "sibling", [
                           TermExp ("sally", []);
                           TermExp ("erica", [])
                       ]
                   );
                   TermExp (
                       "sibling", [
                           TermExp ("john", []);
                           TermExp ("joe", [])
                       ]
                   )
                ])
            );

            (* Combinations *)
            "cat(tom). animal(X) :- cat(X). ?- animal(X).", (
                Clause (
                    TermExp (
                        "cat", [
                            TermExp ("tom", [])
                        ]
                    ), [
                        TermExp ("true", [])
                    ]
                )
            );
        ]
    )

let parser_failure_test_suite =
    "Parser_failure" >::: (
        List.map (
            fun arg ->
                let title =
                    arg
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal
                        None (try_parse arg)
                )
        )
        [
            (* Empty string *)
            "";

            (* Constants *)
            "9";
            "3.14";
            "\"Merry Christmas\"";
            "VAR";

            (* Facts *)
            ".";
            "cat";
            "cat 9";
            "cat,";
            "cat:-";
            "cat((";
            "cat(X.";
            "cat(, X).";
            "(cat).";
            "cat, dog.";
            "coord(X, Y, Z)";
            "coord(X, Y, Z.";
            "coord X, Y, Z).";
            "coord X, Y, Z.";
            "coord(X Y Z).";
            "coord(X, Y, Z, ).";
            "coord(, X, Y, Z).";
            "VAR().";

            (* Rules *)
            ":-";
            ":- cat(X).";
            "cat(X) :-.";
            "cat() :- cat() cat().";
            "parent_child(Z, X), parent_child(Z, Y) :- sibling(X, Y).";

            (* Queries *)
            "?-";
            "?- 9.";
            "cat(tom) ?-";
            "cat(tom) ?- mouse(jerry).";
            "cat(tom), dog(spike) ?- mouse(jerry).";
        ]
    )
