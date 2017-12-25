open OUnit2
open Ast
open Common
open Parser


let string_of_string s = s

let common_test_suite =
    "Common" >::: (
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
            (* Tokens *)
            string_of_token (INT 7),        "INT 7";
            string_of_token (FLOAT 7.0),    "FLOAT 7.";
            string_of_token (STRING "\n"),  "STRING \"\\n\"";
            string_of_token (ATOM "\t"),    "ATOM \"\\t\"";
            string_of_token (VAR "FOO"),    "VAR \"FOO\"";
            string_of_token RULE,           "RULE";
            string_of_token QUERY,          "QUERY";
            string_of_token PERIOD,         "PERIOD";
            string_of_token LPAREN,         "LPAREN";
            string_of_token RPAREN,         "RPAREN";
            string_of_token COMMA,          "COMMA";
            string_of_token SEMICOLON,      "SEMICOLON";
            string_of_token EOF,            "EOF";

            string_of_token_list [
                ATOM "cat"; LPAREN; ATOM "tom"; RPAREN; PERIOD
            ], "[ATOM \"cat\"; LPAREN; ATOM \"tom\"; RPAREN; PERIOD]";

            (* Constants *)
            string_of_const (IntConst (-3)),    "IntConst -3";
            string_of_const (FloatConst 27.3),  "FloatConst 27.3";
            string_of_const (StringConst "\n"), "StringConst \"\\n\"";
            string_of_const (BoolConst true),   "BoolConst true";
            string_of_const (BoolConst false),  "BoolConst false";

            (* Expressions *)
            string_of_exp (VarExp "X"),             "VarExp \"X\"";
            string_of_exp (ConstExp (IntConst 5)),  "ConstExp (IntConst 5)";
            string_of_exp (
                TermExp ("coord", [VarExp "X"; VarExp "Y"; VarExp "Z"])
            ), "TermExp (\"coord\", [VarExp \"X\"; VarExp \"Y\"; VarExp \"Z\"])";
            string_of_exp (
                ConjunctionExp (TermExp ("cat", []), TermExp ("dog", []))
            ), "ConjunctionExp (TermExp (\"cat\", []), TermExp (\"dog\", []))";
            string_of_exp (
                DisjunctionExp (TermExp ("cat", []), TermExp ("dog", []))
            ), "DisjunctionExp (TermExp (\"cat\", []), TermExp (\"dog\", []))";

            (* Declarations *)
            string_of_dec (
                Clause (TermExp ("cat", []), ConstExp (BoolConst true))
            ), "Clause (TermExp (\"cat\", []), ConstExp (BoolConst true))";
            string_of_dec (
                Query (TermExp ("cat", [TermExp ("tom", [])]))
            ), "Query (TermExp (\"cat\", [TermExp (\"tom\", [])]))";

            (* Database *)
            string_of_db [
                Clause (TermExp ("foo", []), ConstExp (BoolConst true));
                Query (TermExp ("bar", []))
            ], "[Clause (TermExp (\"foo\", []), ConstExp (BoolConst true)); Query (TermExp (\"bar\", []))]";

            (print_db [
                Clause (TermExp ("foo", []), ConstExp (BoolConst true));
                Query (TermExp ("bar", []))
            ]; "print_db"), "print_db";

        ]
    )
