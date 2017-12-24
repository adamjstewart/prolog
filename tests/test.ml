open OUnit2
open Lexer_test
open Parser_test


let suite = "suite" >::: [
    lexer_test_suite;
    lexer_failure_test_suite;
    parser_test_suite;
]

let () = run_test_tt_main suite
