open OUnit2
open Common_test
open Lexer_test
open Parser_test
open Evaluator_test


let suite = "suite" >::: [
    common_test_suite;
    lexer_test_suite;
    lexer_failure_test_suite;
    parser_test_suite;
    parser_failure_test_suite;
    evaluator_test_suite;
]

let () = run_test_tt_main suite
