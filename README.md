# prolog

[![Build Status](https://travis-ci.org/adamjstewart/prolog.svg?branch=master)](https://travis-ci.org/adamjstewart/prolog)
[![Coverage Status](https://coveralls.io/repos/github/adamjstewart/prolog/badge.svg?branch=master)](https://coveralls.io/github/adamjstewart/prolog?branch=master)

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

* [Sphinx](http://www.sphinx-doc.org/en/stable/) for building the documentation
* [Sphinx_rtd_theme](https://github.com/rtfd/sphinx_rtd_theme) for the HTML theme
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

To build the documentation, simply run `make html`:

```
$ cd docs
$ make html
```
