Implementation
==============

Capabilities
------------

.. todo:: the major tasks or capabilities of your code

Components
----------

.. todo:: components of the code

Build System
^^^^^^^^^^^^

In order to build the project, we used the `OCamlbuild <https://github.com/ocaml/ocamlbuild>`_ build system. OCamlbuild allowed us to write a greatly simplified Makefile, as OCamlbuild performs a static analysis of the code to determine the correct order in which to build and link every file. Our Makefile has both ``native`` and ``byte`` targets to build either a native or bytecode executable, respectively. OCamlbuild uses `OCamlfind <http://projects.camlcity.org/projects/findlib.html>`_ to locate external dependencies like Menhir.

To view our OCamlbuild configuration, see ``_tags``.

Abstract Syntax Tree
^^^^^^^^^^^^^^^^^^^^

``ast.ml`` contains the types needed to represent an abstract syntax tree of a prolog program. Each line of the program is either a *clause* or a *query*. There are two types of clauses: *rules* and *facts*.

Rules
"""""

A *rule* in prolog takes the form:

.. code-block:: prolog

   Head :- Body.


For example, a complex rule of the form:

.. code-block:: prolog

   sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).


can be represented with the following abstract syntax tree:

.. code-block:: ocaml

   Clause (
       TermExp ("sibling", [VarExp "X"; VarExp "Y"]),
       [
           TermExp ("parent_child", [VarExp "Z"; VarExp "X"]),
           TermExp ("parent_child", [VarExp "Z"; VarExp "Y"])
       ]
   )


Facts
"""""

In prolog, a rule with no body is called a *fact*. As an example, the fact:

.. code-block:: prolog

   cat(tom).


is syntactic sugar for the rule:

.. code-block:: prolog

   cat(tom) :- true.


and is represented as an abstract syntax tree in a way that reflects this:

.. code-block:: ocaml

   Clause (
       TermExp ("cat", [TermExp ("tom", [])]),
       [
           ConstExp (BoolConst true)
       ]
   )


Queries
"""""""

A query is in inquiry into the state of the database, and takes the form:

.. code-block:: prolog

   ?- Body.


For example, a query of the form:

.. code-block:: prolog

   ?- sibling(sally, erica).


can be represented with the following abstract syntax tree:

.. code-block:: ocaml

   Query ([
       TermExp ("sibling", [
           TermExp ("sally", []);
           TermExp ("erica", [])
       ])
   ])


Terms
"""""

In prolog, there is only a single data type, the *term*, which can either be an *atom*, *number*, *variable*, or *compound term*. Compound terms take the form:

.. code-block:: prolog

   functor(arg1, arg2, ...)


In order to simplify the language, we treat atoms as compound terms with arity zero.


Lexer
^^^^^

For lexing, our token list was largely based off of `ECLiPSe Prolog <https://www.cs.uni-potsdam.de/wv/lehre/Material/Prolog/Eclipse-Doc/userman/node139.html>`__. Additional inspiration was taken from `Amzi! Prolog <http://www.amzi.com/manuals/amzi/pro/ref_terms.htm>`_ and `SWI-Prolog <http://www.swi-prolog.org/pldoc/man?section=syntax>`_.

Atoms
"""""

Atoms are identified by alphanumerical tokens starting with a lowercase letter, or any sequence of characters surrounded by single quotes.

Numbers
"""""""

Our lexer supports tokenization of both positive and negative integers, floats, scientific notation, and infinity.

Strings
"""""""

Strings are identified by any sequence of characters surrounded by double quotes. In addition, consecutive strings are automatically concatenated into a single string.

Variables
"""""""""

Variables are identified by alphanumerical tokens starting with a capital letter or underscore.

Comments
""""""""

Our lexer supports line comments (identified by ``%``) and multi-line comments (identified by ``/*`` and ``*/``). Although not all prolog implementations agree on nesting, our lexer supports nested multi-line comments.

Rules
"""""

Our lexer requires five lexing rules: one for general tokens, one for comments, one for atoms, one for strings, and one for escaped character sequences. Since both atoms and strings can contain escaped characters, the rule for handling escape sequences takes a callback rule as a parameter. Our lexer handles both octal and hexadecimal characters in escape sequences.

Parser
^^^^^^

For parsing, our grammar was largely based off of Simon Krenger's `Prolog parser <https://github.com/simonkrenger/ch.bfh.bti7064.w2013.PrologParser/blob/master/doc/prolog-bnf-grammar.txt>`_. Additional inspiration was taken from `ECLiPSe Prolog <https://www.cs.uni-potsdam.de/wv/lehre/Material/Prolog/Eclipse-Doc/userman/node140.html>`__ and `SICStus Prolog <https://sicstus.sics.se/sicstus/docs/3.7.1/html/sicstus_45.html>`_, although we do not support the full range of syntaxes that those implementations do.

The full BNF grammar we support is listed here:

.. productionlist::
   clause: <predicate> . |
         : <predicate> :- <predicate_list> . |
         : ?- <predicate_list> .
   predicate_list: <predicate> |
                 : <predicate> , <predicate_list> |
   predicate: atom |
            : <structure>
   structure: atom ( ) |
            : atom ( <term_list> )
   term_list: <term> |
            : <term> , <term_list>
   term: <constant> |
       : atom |
       : var |
       : <structure>
   constant: int |
           : float |
           : string


Instead of OCamlyacc, we decided to use `Menhir <http://pauillac.inria.fr/~fpottier/menhir/menhir.html.en>`_ as our parser generator. Menhir offers several benefits over OCamlyacc, including more readable error messages and the ability to name semantic values instead of the traditional keywords: ``$1``, ``$2``, etc.

The following graph represents the connections between each non-terminal in our grammar, and was generated using ``menhir --graph`` and `Graphviz <http://www.graphviz.org/>`_:

.. graphviz:: parser.dot


Evaluator
^^^^^^^^^

Status
------

.. todo:: status of the project -- what works well, what works partially, and and what is not implemented at all. You MUST compare these with your original proposed goals in the project proposal.
