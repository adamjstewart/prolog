# prolog

[![Build Status](https://travis-ci.org/adamjstewart/prolog.svg?branch=master)](https://travis-ci.org/adamjstewart/prolog)

An implementation of Prolog written in OCaml

## Dependencies

This project depends on the following OCaml libraries:

* [OCamlfind](https://opam.ocaml.org/packages/ocamlfind/) for finding dependent libraries
* [OCamlbuild](https://opam.ocaml.org/packages/ocamlbuild/) for building the project
* [OUnit](https://opam.ocaml.org/packages/ounit/) for unit testing
* [Menhir](https://opam.ocaml.org/packages/menhir/) for parser generation
* [Bisect_ppx](https://opam.ocaml.org/packages/bisect_ppx/) for coverage analysis
* [Bisect_ppx-ocamlbuild](https://opam.ocaml.org/packages/bisect_ppx-ocamlbuild/) for integration between Bisect_ppx and OCamlbuild
* [OCveralls](https://opam.ocaml.org/packages/ocveralls/) for uploading coverage reports to [Coveralls](https://coveralls.io/)

The recommended way to install these dependencies is with OPAM:

```
$ opam install ocamlfind
$ opam install ocamlbuild
$ opam install oUnit
$ opam install menhir
$ opam install bisect_ppx
$ opam install bisect_ppx-ocamlbuild
$ opam install ocveralls
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
