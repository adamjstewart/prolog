Implementation
==============

Capabilities
------------

We implemented an abstract syntax, parser, lexer, evaluator, and interpreter for a simple version of Prolog in OCaml. The interpreter is used to interact with the user so that the user can input Prolog facts, rules (Horn clauses), or queries and see the output. The user's input is tokenized by our lexer, the tokens are converted into our abstract syntax by our parser, and the abstract syntax tree is then evaluated by our evaluator.

Our components fully support the `grammar <https://github.com/simonkrenger/ch.bfh.bti7064.w2013.PrologParser/blob/master/doc/prolog-bnf-grammar.txt>`_ we mentioned in our project proposal. We support the string, integer, and float Prolog literals. Prolog variables, atoms, and compound terms are fully supported. Prolog facts and rules based on conjunction are also fully supported. Prolog queries consisting of the components mentioned previously are also fully supported.

We also implemented a build system, test suites and framework, and continuous integration to thoroughly test our implementation.

Components
----------

Build System
^^^^^^^^^^^^

In order to build the project, we used the `OCamlbuild <https://github.com/ocaml/ocamlbuild>`_ build system. OCamlbuild allowed us to write a greatly simplified Makefile, as OCamlbuild performs a static analysis of the code to determine the correct order in which to build and link every file. Additionally, OCamlbuild uses `OCamlfind <http://projects.camlcity.org/projects/findlib.html>`_ to locate external dependencies like Menhir.

Our Makefile has both ``native`` and ``byte`` targets to build either a native or bytecode executable, respectively. By default, ``make`` builds a ``main.byte`` executable. When executed, this program provides an interactive interpreter for entering Prolog clauses and queries.

To view our OCamlbuild configuration, see ``_tags``.

Abstract Syntax Tree
^^^^^^^^^^^^^^^^^^^^

``ast.ml`` contains the types needed to represent an abstract syntax tree of a Prolog program. Each line of the program is either a *clause* or a *query*. There are two types of clauses: *rules* and *facts*.

Rules
"""""

A *rule* in Prolog takes the form:

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

In Prolog, a rule with no body is called a *fact*. As an example, the fact:

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
           TermExp ("true", [])
       ]
   )


Queries
"""""""

A query is an inquiry into the state of the database, and takes the form:

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

In Prolog, there is only a single data type, the *term*, which can either be an *atom*, *number*, *variable*, or *compound term*. Compound terms take the form:

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

Our lexer supports line comments (identified by ``%``) and multi-line comments (identified by ``/*`` and ``*/``). Although not all Prolog implementations agree on nesting, our lexer supports nested multi-line comments.

Rules
"""""

Our lexer requires five lexing rules: one for general tokens, one for comments, one for atoms, one for strings, and one for escaped character sequences. Since both atoms and strings can contain escaped characters, the rule for handling escape sequences takes a callback rule as a parameter. This callback tells the lexer which rule to return to after the escaped character sequence has been evaluated. Our lexer handles both octal and hexadecimal characters in escape sequences.

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


Instead of OCamlyacc, we decided to use `Menhir <http://pauillac.inria.fr/~fpottier/menhir/menhir.html.en>`_ as our parser generator. Menhir offers several benefits over OCamlyacc, including more readable error messages and the ability to name semantic values instead of using the traditional keywords: ``$1``, ``$2``, etc.

The following graph represents the connections between each non-terminal in our grammar, and was generated using ``menhir --graph`` and `Graphviz <http://www.graphviz.org/>`_:

.. graphviz:: parser.dot


Evaluator
^^^^^^^^^

The top level function of the evaluator is ``eval_dec`` in ``evaluator.ml``. The function takes in a declaration to evaluate and a database. The database is a list of declarations, more specifically ``ClauseExp``, representing the facts and rules the user has entered so far. The declaration to evaluate can be either a ``ClauseExp``, representing a new fact or rule to add to the database, or a ``QueryExp``, representing a query to answer.

Evaluating a Clause
"""""""""""""""""""

To evaluate a declaration ``d`` that is a ``ClauseExp`` with a database ``db``, the evaluator returns a new database with ``d`` prepended to ``db``. The one exception to this is if ``d`` is giving meaning to the ``true`` atom. We consider ``true`` to be a built-in predicate used only to define facts and thus users are not allowed to redefine it. In the case the user tries to add a clause for the ``true`` atom, a message is printed telling the user that this is not possible and ``db``, the original database, is returned.

Evaluating a Query
""""""""""""""""""

To evaluate a declaration ``d`` that is a ``QueryExp`` (a goal) with a database ``db``, the evaluator has to use the facts and rules in ``db`` to prove all of the subgoals in the query ``d``. A subgoal is an element of the list of ``exp`` that defines a ``QueryExp``. A query asks to prove all of (i.e. the conjunction of) the subgoals. After evaluating all possible results, the evaluator prints each result including the binding of all the variables in the query, if there were any, then prints ``"true"`` if there was at least one result and ``"false"`` otherwise, and returns ``db``, the database passed in.

The Query Evaluation Algorithm
''''''''''''''''''''''''''''''

Our query, or goal, evaluation algorithm was adapted from an algorithm presented by Dr. Hrafn Loftsson of Reykjavik University in one of his `video lectures <https://www.youtube.com/watch?v=BQMSs1wJvnc&t=530s>`_. We used the behavior of query evaluation in `SWI-Prolog <http://www.swi-prolog.org/pldoc/man?section=overview>`__ as the example for our evaluator to follow. This includes things like the order in which subgoals are evaluated and the order in which the database is walked to find rules and facts to prove a subgoal.

The pseudocode for our implementation of the algorithm to evaluate a query ``G`` with a database ``db`` is listed here:

.. code-block:: none

   eval_query (G, db, subs):
     if G is empty:
        return [subs]
     else if G = (g1 :: g):
        results = []
	G' = g
	if g1 = true:
	   results = results @ eval_query(G', db, subs)
	else:
           foreach ClauseExp(h,[b1 .. bn]) in db:
              if unify(g1, h) = σ1:
                 if n = 1 and b1 = true:
	            G' = σ1(g)
	         else:
	            G' = σ1([b1 .. bn] @ g)
	         if unify(σ1 @ subs) = σ2:
		    results = results @ eval_query(G', db,  σ2)
	         else:
	            continue

              else:
	         continue

        return results

The first thing the ``eval_query`` function does is check if ``G`` is empty, meaning that there are no subgoals in ``G`` to prove and that the substitutions in ``subs`` provide one solution for the query. Since there is nothing left to prove for ``G`` the function returns the substitutions inside of a list. This is necessary because at the end ``eval_query`` returns a list of list of substitutions, where each element is a set of substitutions that proved the query.

If ``G`` is not empty, then there is at least one subgoal, ``g1``, to prove and ``g`` is the possibly empty list of other subgoals. Since ``g1`` is the head of the list, it will be the leftmost subgoal in the goal. So we always try to prove the leftmost subgoal, just like how `SWI-Prolog <http://www.swi-prolog.org/pldoc/man?section=overview>`__ does it. If ``g1`` is the ``true`` predicate then we do not need to prove it and can move on to the other subgoals in ``g``. Otherwise, to prove ``g1``, we iterate over the database ``db`` in the order in which the entries in the database were entered and find each rule or fact in the database that matches with ``g1``. A rule or fact matching ``g1`` implies that the rule or fact can be used to prove ``g1``. Since both facts and rules are represented as a ``ClauseExp`` with a head (``h``) and body (``[b1 .. bn]``) component, to match ``g1`` with a rule or fact we use unification on the constraint ``[{g1, h}]``. If unification succeeds and a substitution ``σ1`` is returned, we can use that rule or fact to prove ``g1``. If the entry from the db was a fact, the only subgoals left to prove are in ``g``, so our new goal ``G'`` gets assigned to the result of applying the substitution ``σ1`` to ``g``. If the entry from the db that matched ``g1`` was a rule, then we have more subgoals to prove, more specifically the subgoals from the body of the rule, ``[b1 .. bn]``, along with the other remaining subgoals from ``g``. In this case, ``G'`` is set to the substitution ``σ1`` applied to the result of prepending the body of the rule to ``g``. Then the substitution ``σ1`` is appended to the substitutions passed into ``eval_query``, ``subs``, and the result is unified  to give us a new substitution ``σ2`` for proving this answer. We add to our list of results thus far (``results``) the result of recursively calling ``eval_query`` with ``G'`` as the new goal and ``σ2`` as the new ``subs``. For a subgoal ``g1``, this process happens for each item in the database.

The ``eval_query`` function finds answers to queries in a depth-first fashion as it always recurses after a fact or a rule matches the current leftmost subgoal ``g1``. When that call returns because either ``G'`` was proven or disproven then it continues on to the next fact or rule in the database. Backtracking is inherently handled as the leftmost subgoal ``g1`` is always matched against all rules and facts in the database and if, after checking against each element of the database, the subgoal ``g1`` can not be proven that partial candidate is abandoned. When the iteration over the database is done, only the possible results for a goal ``G`` will be present in ``results``.

Although not shown in the pseudocode, when we pick a clause out of the database, we rename all variables occurring in the clause to fresh variable names. This avoids a mess with variable bindings when the same clause is possibly picked again for evaluating the query.

Below is an example Prolog program and its resulting query evaluation tree. The only unification shown is the one used to match the subgoal against rules and facts from the database. Variables are represented in between double quotes (i.e. ``"Z"``, ``"1"``, ``"X"``, ``"2"``). Variable renaming is shown in the two cases when the rule for ``animal`` is selected from the database for unification and ``"X"`` is renamed to ``"1"`` and ``"2"``. The result for each ``eval_query`` node in the tree contains all the results from all subtrees of that node. In the black font is the database, in red font are the calls that failed, and in the green font are the calls that were successful. The numbers on the edges represent the order in which the nodes are visited.

.. code-block:: prolog

   cat(tom).
   animal(X) :- cat(X).
   cat(jerry).

   ?- animal(Z).

.. image:: query_eval.*


Printing Query Results
''''''''''''''''''''''

Since the evaluator returns a database to the interpreter, the evaluator needs to print the results of the query before returning. If the results are empty the evaluator prints ``false`` for the user and returns. If there is at least 1 item in the results the evaluator prints all of the bindings for the variables from the user's query and then prints ``true`` and returns. For each result in ``result``, for each variable in the user's query, the result is checked for a binding for that variable. If the binding is to another variable or there is no binding then that variable is free and the user gets told that the variable is free. Otherwise, the binding is printed.

The Unification Algorithm
'''''''''''''''''''''''''

Unification is at the center of the query evaluation algorithm. It is used to match a rule or fact from the database to a subgoal to see if that rule or fact can be used to prove the subgoal. It is also used to update the substitutions to use for the ``eval_query`` recursive call when a rule or fact from the database has matched the subgoal. The algorithm is mostly the same as the one that was presented in `lecture 16 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/lectures/15-16-poly-type-infer-unif.pdf>`_ and we implemented for `ML4 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/mps/ML4/>`_ during the semester, except for a few differences.

In our case ``VarExp`` represents a variable, ``TermExp`` represents a functor or atom, and ``ConstExp`` represents a constant integer, float, or string. As such we needed to add an orient case for the situation when there is a constraint ``(s, t)`` where ``s`` is a ``ConstExp`` and ``t`` is a ``VarExp``, a fail case for the situation when there is a constraint ``(s, t)`` where ``s`` is a ``TermExp`` and ``t`` is a ``ConstExp``, and a fail case for the situation when there is a constraint ``(s, t)`` where ``s`` is a ``ConstExp`` and ``t`` is a ``ConstExp`` and ``s != t``.

The modified unification algorithm psuedocode is listed here (inspired by the algorithm that was presented in `lecture 16 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/lectures/15-16-poly-type-infer-unif.pdf>`_):

.. code-block:: none

   let S = {(s1, t1), (s2, t2), ... , (sn, tn)} be a set of constraints

   case S = {}; unify(S) = []

   case S = {(s, t)} ∪ S':
     Delete
        if s = t
	then unify(S) = unify(S')
	else Fail
     Decompose
        if s = TermExp(f, [q1, ... , qm]) and t = TermExp(f, [r1, ... , rm])
	then unify(S) = unify({(q1, r1), ... , (qm, rm)} ∪ S')
	else
           if s = TermExp(f, [q1, ... , qm]) and t = ConstExp(c)
	   then Fail
     Orient
        if t = VarExp(x) and (s = TermExp(f, [q1, ... , qm]) or s = ConstExp(c))
	then unify(S) = unify({(t, s)} ∪ S')
     Eliminate
        if s = VarExp(x) and s does not occur in t
	then
	  let sub = {s -> t};
	  let S'' = sub(S');
	  let phi = unify(S'');
	  unify(S) = {s -> phi(t)} o phi
     Extra Fail Case
        if s = ConstExp(c) and t = ConstExp(d) and s != t
	then Fail

     All other cases cause unify to Fail.


Interpreter
^^^^^^^^^^^

The interpreter, the front-end program in ``main.ml``, is derived from the ``picomlInterp.ml`` file given to us for `MP5 <https://courses.engr.illinois.edu/cs421/fa2017/CS421D/mps/MP5/>`_ during the semester. It essentially loops until the lexer reaches ``EOF`` and raises the ``Lexer.EndInput`` exception. The loop function takes in a list of declarations which is the database that will be used to evaluate whatever declaration the user inputs. The database starts out empty at the start of the interpreter. For each iteration of the loop, a lexbuf is created from user input to standard input, which is then passed into the parser to get the AST representation of the input. The AST representation of the input and the database are passed into the evaluator to evaluate the input and return a, possibly updated, database which is passed into a recursive call of the loop. If there are any exceptions raised by the lexer, parser, or evaluator, a message is printed for the user and the loop is recursively called with the same database that was passed in. The loop ends only when the lexer sees ``EOF``.

Status
------

After thorough testing, we believe our components like the lexer, parser, and evaluator fully implement all of the `grammar <https://github.com/simonkrenger/ch.bfh.bti7064.w2013.PrologParser/blob/master/doc/prolog-bnf-grammar.txt>`_ we mentioned in our proposal.

Although we mentioned in our project proposal that we wanted to support interpretation from both files and a command-line interpreter, our implementation does not support files. We decided to focus on the interpreter for this project.

When we asked for an extension, Professor Gunter suggested we leave strings and numbers out of the implementation unless we had enough time. We implemented string, int, and float constants as well in all components, although we do not support binary operations on these types. Our proposed grammar did not include binary operations on these types.

Major Prolog implementations implement disjunction between subgoals along with conjunction. Implementing disjunction would have significantly complicated our implementation so we did not implement it. Also, the grammar we proposed did not include disjunction between subgoals.

Also, we do not implement Prolog's unification operator ``=`` as well as any other built-in predicate besides the ``true`` predicate. Prolog list types are not implemented either. Again, our proposed grammar did not include these elements. In our implementation, strings and atoms can't be unified, but in major Prolog implementations they can be if they are the same sequence of characters.

One feature we had implemented in the evaluator but later took out was prompting the user after finding a result in query evaluation to see if the user wanted more results. We had implemented this but as this feature requires user interaction, it became very difficult to write unit tests for. This feature is present in all of the major Prolog implementations as it can help avoid a lot of evaluation if the user already got the answer they were looking for. We decided it was better to be able to test the evaluator thoroughly with unit tests than to have this feature so we removed it.

