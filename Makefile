MENHIR = menhir --unused-token EOF
OCB = ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)' -menhir "$(MENHIR)"


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
	@rm -f *.out
