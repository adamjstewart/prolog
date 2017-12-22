open OUnit2
open Common
open Lexer
open Parser


let lexer_test_suite =
    "Lexer" >::: (
        List.map (
            fun (arg, res) ->
                let title =
                    arg
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal res (get_all_tokens arg)
                )
        )
        [
            (* Atoms *)
            "x",            [ATOM "x"];
            "red",          [ATOM "red"];
            "blueBook",     [ATOM "blueBook"];
            "mother_child", [ATOM "mother_child"];
            "'Taco'",       [ATOM "'Taco'"];
            "'some atom'",  [ATOM "'some atom'"];
            "foobar123",    [ATOM "foobar123"];

            (* Numbers *)
            "1",        [INT 1];
            "39",       [INT 39];
            "+48",      [INT (+48)];
            "-320",     [INT (-320)];

            "3.2",      [FLOAT 3.2];
            "0.345",    [FLOAT 0.345];
            "12.0",     [FLOAT 12.0];
            "+9.8",     [FLOAT (+9.8)];
            "-5.6",     [FLOAT (-5.6)];

            "3.3e4",    [FLOAT 3.3e4];
            "3.3E4",    [FLOAT 3.3E4];
            "3e4",      [FLOAT 3e4];
            "3E4",      [FLOAT 3E4];
            "-7.5e-54", [FLOAT (-7.5e-54)];

            "1.0Inf",   [FLOAT infinity];
            "5.3Inf",   [FLOAT infinity];
            "-1.0Inf",  [FLOAT neg_infinity];
            "-2.4Inf",  [FLOAT neg_infinity];

            (* Strings *)
            "\"Hello, World!\"",                [STRING "Hello, World!"];
            "\"Hello, \" \"World!\"",           [STRING "Hello, World!"];
            "\"really long\\nwrapped line\"",   [STRING "really long\nwrapped line"];

            (* Variables *)
            "Cats",     [VAR "Cats"];
            "_dogs",    [VAR "_dogs"];
            "FOOBAR",   [VAR "FOOBAR"];

            (* Symbols *)
            ":-",       [RULE];
            "?-",       [QUERY];
            ".",        [PERIOD];
            "(",        [LPAREN];
            ")",        [RPAREN];
            ",",        [COMMA];
            ";",        [SEMICOLON];

            (* Combinations *)
            "cat(tom).", [
                ATOM "cat"; LPAREN; ATOM "tom"; RPAREN; PERIOD
            ];
            "cat(tom) :- true.", [
                ATOM "cat"; LPAREN; ATOM "tom"; RPAREN; RULE; ATOM "true"; PERIOD
            ];
            "cat(tom):-true.", [
                ATOM "cat"; LPAREN; ATOM "tom"; RPAREN; RULE; ATOM "true"; PERIOD
            ];
            "?- cat(tom).", [
                QUERY; ATOM "cat"; LPAREN; ATOM "tom"; RPAREN; PERIOD
            ];
            "?- cat(X).", [
                QUERY; ATOM "cat"; LPAREN; VAR "X"; RPAREN; PERIOD
            ];
            "?-cat(X).", [
                QUERY; ATOM "cat"; LPAREN; VAR "X"; RPAREN; PERIOD
            ];
            "sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).", [
                ATOM "sibling"; LPAREN; VAR "X"; COMMA; VAR "Y"; RPAREN; RULE;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "X"; RPAREN; COMMA;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "Y"; RPAREN; PERIOD
            ];
        ]
    )
