open OUnit2
open Lexer_test


let suite = "suite" >::: [
    lexer_test_suite;
]

let () = run_test_tt_main suite
