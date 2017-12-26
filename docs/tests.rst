Tests
=====

When building a complex project like an interpreter, stability is crucial. Our prolog implementation comes with a wide variety of tests to detect and prevent bugs.

Unit Tests
----------

In order to write unit tests, we used the [OUnit](http://ounit.forge.ocamlcore.org) unit test framework for OCaml. OUnit provides several convenience functions for writing simple test suites. It also provides several useful command-line arguments to enable more specific testing requests.

All unit tests can be found in the ``tests`` directory.

Documentation Tests
-------------------

Continuous Integration (CI)
---------------------------

Coverage
--------
