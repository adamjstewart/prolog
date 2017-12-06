SOURCES = \
	src/common \
	src/lexer.mll \

RESULT = bin/prologInterp
  
OCAMLMAKEFILE = OCamlMakefile
include $(OCAMLMAKEFILE)
