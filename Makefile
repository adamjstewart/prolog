MENHIR = menhir --unused-token EOF
OCB = ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)' -menhir "$(MENHIR)"


.PHONY: all native byte test coverage clean


all: byte

native:
	$(OCB) main.native

byte:
	$(OCB) main.byte

test:
	$(OCB) test.byte
	./test.byte

coverage:
	BISECT_COVERAGE=YES \
	BISECT_FILE=_build/coverage \
	$(OCB) test.byte
	./test.byte
	bisect-ppx-report -I _build -html _build _build/coverage*.out
	open _build/index.html

clean:
	$(OCB) -clean
