Overview
========

We implement a simple version of Prolog in OCaml using the material we learned in the course.


Motivation
----------

Prolog is a logic programming language used in fields like artificial intelligence.

Facts and rules (i.e. Horn Clauses) are used to express the program logic in Prolog. Prolog computation involves querying a database of facts and rules. If a given query can be proven for a given database, Prolog outputs the answers for the query and a message like "Yes" or "true" to tell the user that the query was proven. If the query can't be proven, either a message like "false" or an error is outputted to the user. A query can have comma separated subgoals and the evaluation of the query is the evaluation of the conjunction between all of the subgoals.

In the Prolog program below, ``cat(tom)`` and ``animal(X)`` are both compound terms, ``tom`` is an atom, ``X`` is a variable, ``cat(tom).`` is a fact, ``animal(X) :- cat(X).`` is a rule (or Horn Clause), and ``?- animal(X).`` is a query. In this program, the query ``?- animal(X).`` evaluates to true where the one and only mapping for the variable ``X`` is ``X = tom``.

.. code-block:: prolog

   cat(tom).
   animal(X) :- cat(X).

   ?- animal(X).

The unification algorithm, similar to the one that was presented in `lecture 16 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/lectures/15-16-poly-type-infer-unif.pdf>`_ and we implemented for `ML4 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/mps/ML4/>`_ during the semester, is at the center of query evaluation in Prolog. The lexer and parser for Prolog can be implemented in a similar way to how we implemented a lexer and parser for PicoML in `MP4 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/mps/MP4/>`_ and `ML5 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/mps/ML5/>`_, respectively, during the semester. Thus, this project should thoroughly test our understanding of some of the most important topics from the course.

Goals
-----

When we looked at different Prolog implementations, we were surprised by how different they were from one another. We therefore proposed that our implementation would fully support Simon Krenger's `Prolog grammar <https://github.com/simonkrenger/ch.bfh.bti7064.w2013.PrologParser/blob/master/doc/prolog-bnf-grammar.txt>`_. Based on this grammar, we planned on supporting string, integer, and float literals, variables, atoms, facts, rules based on conjunction, and queries based on conjunction of the subgoals in the query. We also proposed that our implementation would be able to interpret from both files and a command-line interpreter.

As we were not able to finish this project during the semester, we had to ask for an extension. Professor Gunter suggested we modify our original project proposal and leave string, integer, and float literals out of our implementation unless we had enough time.

Accomplishments
---------------

Our final implementation implements all of the goals we proposed in our initial project proposal except for the ability to interpret from files. We had enough time to support string, integer, and float literals as well.

Our implementation supports moderately complicated queries based on conjunction of the subgoals in the query.

We have also implemented a detailed testing framework with test suites for each one of the major components in our implementation.
