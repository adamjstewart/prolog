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
                        assert_equal
                        ~printer:string_of_token_list
                        res (get_all_tokens arg)
                )
        )
        [
            (* Empty string *)
            "",                         [];
            "\n",                       [];
            "\t",                       [];

            (* Atoms *)
            "x",                        [ATOM "x"];
            "red",                      [ATOM "red"];
            "blueBook",                 [ATOM "blueBook"];
            "mother_child",             [ATOM "mother_child"];
            "'Taco'",                   [ATOM "Taco"];
            "'some atom'",              [ATOM "some atom"];
            "foobar123",                [ATOM "foobar123"];
            "'foo\"bar'",               [ATOM "foo\"bar"];
            "'foo\"\\'bar'",            [ATOM "foo\"'bar"];
            "' \\t\\n '",               [ATOM " \t\n "];
            "'\\a\\b\\f\\n\\r\\t\\v\\e\\d'", [
                ATOM "\007\b\012\n\r\t\011\027\127"
            ];
            "'\\\\'",                   [ATOM "\\"];
            "'\\\n'",                   [ATOM ""];
            "'\\c   \n   \n  '",        [ATOM ""];
            "'\\125\\111\\125\\103'",   [ATOM "UIUC"];
            "'\\x43\\\\x53\\'",         [ATOM "CS"];

            (* Numbers *)
            "1",        [INT 1];
            "39",       [INT 39];
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
            "\"Hello,\" \"World!\"",            [STRING "Hello,World!"];
            "\"really long\\nwrapped line\"",   [STRING "really long\nwrapped line"];
            "\"I'm can't\"",                    [STRING "I'm can't"];
            "\"foo\\\"'bar\"",                  [STRING "foo\"'bar"];
            "\" \\t\\n \"",                     [STRING " \t\n "];
            "\"\\a\\b\\f\\n\\r\\t\\v\\e\\d\"",  [STRING "\007\b\012\n\r\t\011\027\127"];
            "\"\\\\\"",                         [STRING "\\"];
            "\"\\\n\"",                         [STRING ""];
            "\"\\c   \n   \n  \"",              [STRING ""];
            "\"\\125\\111\\125\\103\"",         [STRING "UIUC"];
            "\"\\x43\\\\x53\\\"",               [STRING "CS"];

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
            ":- ?- ()", [RULE; QUERY; LPAREN; RPAREN];

            (* Comments *)
            "cat(tom). % tom is a cat\nmouse(jerry). % jerry is a mouse", [
                ATOM "cat";   LPAREN; ATOM "tom";   RPAREN; PERIOD;
                ATOM "mouse"; LPAREN; ATOM "jerry"; RPAREN; PERIOD
            ];
            "this line /* contains a\nmulti-line */ comment.", [
                ATOM "this"; ATOM "line"; ATOM "comment"; PERIOD
            ];
            "this /* line /* contains /* several */ nested */ comments */ in a row", [
                ATOM "this"; ATOM "in"; ATOM "a"; ATOM "row"
            ];

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
                ATOM "sibling";      LPAREN; VAR "X"; COMMA; VAR "Y"; RPAREN; RULE;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "X"; RPAREN; COMMA;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "Y"; RPAREN; PERIOD
            ];
            "sibling(X,Y):-parent_child(Z,X),parent_child(Z,Y).", [
                ATOM "sibling";      LPAREN; VAR "X"; COMMA; VAR "Y"; RPAREN; RULE;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "X"; RPAREN; COMMA;
                ATOM "parent_child"; LPAREN; VAR "Z"; COMMA; VAR "Y"; RPAREN; PERIOD
            ];
        ]
    )

let lexer_failure_test_suite =
    "Lexer_failure" >::: (
        List.map (
            fun arg ->
                let title =
                    arg
                in
                title >:: (
                    fun test_ctxt ->
                        assert_equal
                        None (try_get_all_tokens arg)
                )
        )
        [
            (* Comments *)
            "*/";
            "/* */ */";

            "/*";
            "/* /* */";

            (* Invalid characters *)
            "\r";
            "\b";
        ]
    )
