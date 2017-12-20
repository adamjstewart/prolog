# prolog

An implementation of Prolog written in OCaml

## Dependencies

This project depends on the following OCaml libraries:

* [OCamlfind](https://opam.ocaml.org/packages/ocamlfind/) for finding dependent libraries
* [OCamlbuild](https://opam.ocaml.org/packages/ocamlbuild/) for building the project
* [OUnit](https://opam.ocaml.org/packages/ounit/) for unit testing
* [Menhir](https://opam.ocaml.org/packages/menhir/) for parser generation

The recommended way to install these dependencies is with OPAM:

```
$ opam install ocamlfind
$ opam install ocamlbuild
$ opam install ounit
$ opam install menhir
```

## Installation

To build this project, simply clone the repository and run `make`:

```
$ git clone https://github.com/adamjstewart/prolog.git
$ cd prolog
$ make
```

## Testing

To run the test-suite, simply run `make test`:

```
$ make test
```
