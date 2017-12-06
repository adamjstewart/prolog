OCB = ocamlbuild -use-ocamlfind


.PHONY: all native byte test clean


all: byte

native:
	$(OCB) main.native

byte:
	$(OCB) main.byte

test:
	$(OCB) test.byte
	./test.byte

clean:
	$(OCB) -clean
