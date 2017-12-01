{
open Common;;
}

(* You can assign names to commonly-used regular expressions in this part
   of the code, to save the trouble of re-typing them each time they are used *)

(* Refer to:

   https://www.cs.uni-potsdam.de/wv/lehre/Material/Prolog/Eclipse-Doc/userman/node139.html
   http://www.amzi.com/manuals/amzi/pro/ref_terms.htm

   for token list *)

(* Character classes *)
let upper_case = ['A' - 'Z']
let underline = '_'
let lower_case = ['a' - 'z']
let digit = ['0' - '9']
let blank_space = [' ' '\t']
let end_of_line = '\n'
let atom_quote = '''
let string_quote = '"'
let solo = ['(' ')' ']' '}']
let special = ['!' ',' ';' '[' '{' '|']
let line_comment = '%' [^ '\n'] *
let escape = '\'
let first_comment = '/'
let second_comment = '*'
let symbol = ['#' '+' '-' '.' ':' '<' '=' '>' '?' '@' '^' '`' '~' '$' '&']

(* Groups of characters *)
let alphanumerical = upper_case | underline | lower_case | digit
let delimiter = [')' '}' ']' ',' '|']
let any_character = ['A' - 'Z' 'a' - 'z' '0' - '9' ' ' '`' '~' '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '-' '_' '=' '+' '[' ']' '{' '}' '|' ';' ':' ''' ',' '.' '<' '>' '/' '?' '\']
let non_escape = any_character # ['\']
let sign = ['+' '-']

let atom =
      (lowercase alphanumerical *)
    | (symbol | first_comment | second_comment | escape ) +
    | (atom_quote (non_escape | escape any_character +) * atom_quote)
    | '|'
    | ';'
    | "[]"
    | "{}"
    | '!'

let digits = digit +
let integers = sign ? digits
let rationals = (integers) underline (digits)
let floats =
      integers '.' digits (['e' 'E'] sign ? digits | "Inf") ?
    | integers ['e' 'E'] sign ? digits

let variable = (upper_case | underscore) alphanumeric *

rule token = parse
    (* Meta-characters *)
    | [' ' '\t' '\n']       { token lexbuf }  (* skip over whitespace *)
    | comment               { token lexbuf }  (* skip over line comments *)
    | eof                   { EOF }

    (* Atoms *)
    | atom as a             { ATOM a }

    (* Numbers *)
    | integers as n         { INT (int_of_string n) }
    | rationals as (n, d)   { RAT (int_of_string n, int_of_string d) }
    | floats as f           { FLOAT (float_of_string f) }

    (* Strings *)
    | string_quote          { string_parser "" lexbuf }

    (* Variables *)
    | variable as v         { VAR v }

and string_parser acc = parse
    (* By default, consecutive strings are concatenated into a single string. *)
    | string_quote blank_space * string_quote   { string_parser acc }
    | '"'                                       { STRING acc }
    | non_escape as s                           { string_parser (acc ^ (String.make 1 s)) lexbuf }
    | "\\a"                                     { string_parser (acc ^ (String.make 1 (Char.chr 7))) lexbuf }
    | "\\b"                                     { string_parser (acc ^ (String.make 1 (Char.chr 8))) lexbuf }
    | "\\f"                                     { string_parser (acc ^ (String.make 1 (Char.chr 12))) lexbuf }
    | "\\n"                                     { string_parser (acc ^ (String.make 1 (Char.chr 10))) lexbuf }
    | "\\r"                                     { string_parser (acc ^ (String.make 1 (Char.chr 13))) lexbuf }
    | "\\t"                                     { string_parser (acc ^ (String.make 1 (Char.chr 9))) lexbuf }
    | "\\v"                                     { string_parser (acc ^ (String.make 1 (Char.chr 11))) lexbuf }
    | "\\e"                                     { string_parser (acc ^ (String.make 1 (Char.chr 27))) lexbuf }
    | "\\d"                                     { string_parser (acc ^ (String.make 1 (Char.chr 127))) lexbuf }
    | "\\\\"                                    { string_parser (acc ^ "\\") lexbuf }
    | "\\'"                                     { string_parser (acc ^ "'") lexbuf }
    | "\\\""                                    { string_parser (acc ^ "\"") lexbuf }
    | "\\\n"                                    { string_parser acc lexbuf }
    | "\\c" (blank_space end_of_line) *         { string_parser acc lexbuf }

{
let lextest s = token (Lexing.from_string s)

let get_all_tokens s =
    let b = Lexing.from_string (s^"\n") in
    let rec g () =
    match token b with EOF -> []
    | t -> t :: g () in
        g ()

let try_get_all_tokens s =
    try (Some (get_all_tokens s), true)
    with Failure "unmatched open comment" -> (None, true)
       | Failure "unmatched closed comment" -> (None, false)
}

