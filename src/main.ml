open Ast
open Common
open Lexer
open Parser
open Evaluator


(* Try to detect if something is getting piped in *)
let is_interactive = 0 = (Sys.command "[ -t 0 ]")

let _ =
    (if is_interactive
     then print_endline "\nWelcome to the Prolog Interpreter\n"
     else ()
    );
    let rec loop db = (
        try (
            let lexbuf = Lexing.from_channel stdin
            in (
                if is_interactive
                then (print_string "> "; flush stdout)
                else ()
            );
            let dec = clause (
                fun lb -> (
                    match Lexer.token lb with
                    | EOF -> raise Lexer.EndInput
		    | r -> r
		)
	    ) lexbuf
            (* evaluate dec and get a new db *)
            in let newdb = eval_dec (dec,db)
            in loop newdb (* loop again with new db *)
        )
        (* exception raised *)
        with
        | Failure s -> ( (* in case of an error *)
            print_newline();
	    print_endline s;
            print_newline();
            loop db
        )
        | Parser.Error -> ( (* failed to parse input *)
            print_string "\nDoes not parse\n";
            loop db
        )
        | Lexer.EndInput -> exit 0 (* EOF *)
        | _ -> ( (* Any other error *)
            print_string "\nUnrecognized error\n";
            loop db
        )
    )
    in (loop [])
