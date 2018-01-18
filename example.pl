1. Fairly complicated family tree.

                              James I
                                 |
                                 |
                +----------------+-----------------+
                |                |                 |
             Charles I         Fred             Elizabeth
                |                                  |
                |                                  |
     +----------+------------+                     |
     |          |            |                     |
 Catherine   Charles II   James II               Sophia
                                                   |
                                                   |
                                                   |
                                                George I


Here are the resultant clauses:
-------------------------------
male(james1).
male(charles1).
male(charles2).
male(james2).
male(george1).
male(fred).    

female(catherine).
female(elizabeth).
female(sophia).

parent(charles1, james1).
parent(elizabeth, james1).
parent(charles2, charles1).
parent(catherine, charles1).
parent(james2, charles1).
parent(sophia, elizabeth).
parent(george1, sophia).
parent(fred, james1).



?- male(george1).
?- parent(sophia, sophia).
?- parent(X, charles1).
?- parent(X, Y), male(X).
?- parent(X, Y), male(X), male(Y).


father(X, Y) :- parent(X, Y), male(Y).
son(X, Z) :- parent(X, Z), male(X).    
father_son(X, Y) :- father(X, Y), son(X, Y).    

?- father_son(X, Y).

whoami(I, You) :- father(You, F1), father(F1, F2), son(I, F2).
    
?- whoami(I, You).
    
