{
    open Parser


    exception EndInput
}

(* Refer to:

   https://www.cs.uni-potsdam.de/wv/lehre/Material/Prolog/Eclipse-Doc/userman/node139.html
   http://www.amzi.com/manuals/amzi/pro/ref_terms.htm

   for a list of valid tokens *)

(* Character classes *)
let upper_case = ['A' - 'Z']
let underline = '_'
let lower_case = ['a' - 'z']
let digit = ['0' - '9']
let blank_space = [' ' '\t']
let end_of_line = '\n'
let atom_quote = '''
let string_quote = '"'
let line_comment = '%' [^ '\n'] *
let open_comment = "/*"
let close_comment = "*/"
let escape = '\\'

(* Groups of characters *)
let alphanumerical = upper_case | underline | lower_case | digit
let any_character = [' ' - '~']
let non_escape = any_character # ['\\']
let sign = ['+' '-']

(* Atoms *)
let atom = lower_case alphanumerical *
let octal = ['0' - '7']
let octals = octal octal octal
let hex = ['0' - '9' 'A' - 'F' 'a' - 'f']
let hexes = 'x' hex + escape

(* Numbers *)
let digits = digit +
let integers = sign ? digits
let floats =
      integers '.' digits (['e' 'E'] sign ? digits) ?
    | integers ['e' 'E'] sign ? digits
let inf = '+' ? digits '.' digits "Inf"
let neg_inf = '-' digits '.' digits "Inf"

(* Variables *)
let variable = (upper_case | underline) alphanumerical *

rule token = parse
    (* Meta-characters *)
    | [' ' '\t' '\n']       { token lexbuf }
    | eof                   { EOF }

    (* Comments *)
    | line_comment          { token lexbuf }
    | open_comment          { comments 1 lexbuf }
    | close_comment         { raise (Failure "unmatched closed comment") }

    (* Atoms *)
    | atom as a             { ATOM a }
    | atom_quote            { atoms "" lexbuf }

    (* Numbers *)
    | integers as n         { INT   (int_of_string n)   }
    | floats   as f         { FLOAT (float_of_string f) }
    | inf                   { FLOAT infinity            }
    | neg_inf               { FLOAT neg_infinity        }

    (* Strings *)
    | string_quote          { strings "" lexbuf }

    (* Variables *)
    | variable as v         { VAR v }

    (* Symbols *)
    | ":-"                  { RULE      }
    | "?-"                  { QUERY     }
    | '.'                   { PERIOD    }
    | '('                   { LPAREN    }
    | ')'                   { RPAREN    }
    | ','                   { COMMA     }

and comments count = parse
    | open_comment          { comments (1 + count) lexbuf }
    | close_comment         { match count with
                              | 1 -> token lexbuf
                              | n -> comments (n - 1) lexbuf
                            }
    | eof                   { raise (Failure "unmatched open comment") }
    | _                     { comments count lexbuf }

and strings acc = parse
    (* Consecutive strings are concatenated into a single string *)
    | string_quote blank_space * string_quote   { strings acc lexbuf }
    | string_quote                              { STRING acc }
    | non_escape # ['"'] + as s                 { strings (acc ^ s) lexbuf }
    | escape                                    { escaped strings acc lexbuf }

and atoms acc = parse
    | atom_quote                        { ATOM acc }
    | non_escape # ['''] + as a         { atoms (acc ^ a) lexbuf }
    | escape                            { escaped atoms acc lexbuf }

and escaped callback acc = parse
    | 'a'                               { callback (acc ^ (String.make 1 (char_of_int   7))) lexbuf }
    | 'b'                               { callback (acc ^ (String.make 1 (char_of_int   8))) lexbuf }
    | 'f'                               { callback (acc ^ (String.make 1 (char_of_int  12))) lexbuf }
    | 'n'                               { callback (acc ^ (String.make 1 (char_of_int  10))) lexbuf }
    | 'r'                               { callback (acc ^ (String.make 1 (char_of_int  13))) lexbuf }
    | 't'                               { callback (acc ^ (String.make 1 (char_of_int   9))) lexbuf }
    | 'v'                               { callback (acc ^ (String.make 1 (char_of_int  11))) lexbuf }
    | 'e'                               { callback (acc ^ (String.make 1 (char_of_int  27))) lexbuf }
    | 'd'                               { callback (acc ^ (String.make 1 (char_of_int 127))) lexbuf }
    | escape                            { callback (acc ^ "\\") lexbuf }
    | atom_quote                        { callback (acc ^  "'") lexbuf }
    | string_quote                      { callback (acc ^ "\"") lexbuf }
    | end_of_line                       { callback acc lexbuf }
    | 'c' (blank_space | end_of_line) * { callback acc lexbuf }
    | octals as o                       { callback (acc ^ (String.make 1 (char_of_int (
                                            int_of_string ("0o" ^ o))))) lexbuf }
    | hexes as h                        { callback (acc ^ (String.make 1 (char_of_int (
                                            int_of_string ("0" ^ (String.sub h 0 (
                                                (String.length h) - 1))))))) lexbuf }

{
    (* Takes a string s and returns a list of tokens generated by lexing s *)
    let get_all_tokens s =
        let b = Lexing.from_string (s ^ "\n") in
            let rec g () =
                match token b with
                | EOF -> []
                | t -> t :: g () in
                    g ()

    (* Takes a string s and returns Some of a list of tokens or None *)
    let try_get_all_tokens s =
        try Some (get_all_tokens s) with
        | Failure _ -> None
}
