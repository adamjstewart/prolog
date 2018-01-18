# prolog

[![Build Status](https://travis-ci.org/adamjstewart/prolog.svg?branch=master)](https://travis-ci.org/adamjstewart/prolog)
[![Coverage Status](https://coveralls.io/repos/github/adamjstewart/prolog/badge.svg?branch=master)](https://coveralls.io/github/adamjstewart/prolog?branch=master)
[![Documentation Status](https://readthedocs.org/projects/prolog/badge/?version=latest)](http://prolog.readthedocs.io/en/latest/?badge=latest)

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


The recommended way to install these dependencies is with [OPAM](https://opam.ocaml.org/):

```
$ opam install ocamlfind
$ opam install ocamlbuild
$ opam install oUnit
$ opam install menhir
$ opam install bisect_ppx
$ opam install bisect_ppx-ocamlbuild
$ opam install ocveralls
```

Additionally, in order to build the documentation, the following dependencies are required:

* [Sphinx](https://pypi.python.org/pypi/Sphinx) for building the documentation
* [Sphinx_rtd_theme](https://pypi.python.org/pypi/sphinx_rtd_theme) for the HTML theme
* [Graphviz](http://www.graphviz.org/) for rendering the parser graph
* [LaTeX](https://www.latex-project.org/) for building a PDF version

The recommended way to install these dependencies is with [pip](https://pip.pypa.io/en/stable/):

```
$ pip install sphinx
$ pip install sphinx_rtd_theme
```

## Installation

To build this project, simply clone the repository and run `make`:

```
$ git clone https://github.com/adamjstewart/prolog.git
$ cd prolog
$ make
```

Afterwards, the interpreter can be run like so:

```
$ ./main.byte

Welcome to the Prolog Interpreter

> cat(tom).
> animal(X) :- cat(X).
> ?- animal(X).
====================
X = tom
====================
true
```

## Testing

To run the test-suite, simply run `make test`:

```
$ make test
```

## Coverage

To generate and view the coverage reports in your web browser, simply run `make coverage`:

```
$ make coverage
```

## Documentation

To build the documentation, simply run `make docs`:

```
$ make docs
```
