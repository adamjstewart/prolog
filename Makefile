MENHIR = menhir --unused-token EOF
OCB = ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)' -menhir "$(MENHIR)" 


.PHONY: all native byte test coverage docs clean


all: byte

native:
	$(OCB) main.native

byte:
	$(OCB) main.byte

test:
	$(OCB) test.byte
	./test.byte

coverage: export BISECT_COVERAGE=YES
coverage: export BISECT_FILE=_build/coverage
coverage: clean
	$(OCB) test.byte
	./test.byte
	bisect-ppx-report -I _build -html _build _build/coverage*.out
	open _build/index.html

docs:
	cd docs && make html SPHINXOPTS=-W

clean:
	$(OCB) -clean
