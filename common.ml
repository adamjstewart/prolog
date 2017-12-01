(* File: common.ml *)

type token =
  | ATOM of string
  | INT of int
  | RAT of int * int
  | FLOAT of float
  | VAR of string
  | STRING of string
  | EOF

