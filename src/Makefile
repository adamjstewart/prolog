# Commands
OCAMLC    = ocamlc
OCAMLLEX  = ocamllex
OCAMLYACC = ocamlyacc
RM        = rm
MKDIR     = mkdir

# Files
LEXER  = lexer
COMMON = common

.PHONY: all clean

all: $(LEXER).cmo $(COMMON).cmo

$(LEXER).cmo: $(LEXER).ml $(COMMON).cmo
	$(OCAMLC) -c $(LEXER).ml

$(LEXER).ml: $(LEXER).mll
	$(OCAMLLEX) $(LEXER).mll

$(COMMON).cmo: $(COMMON).ml
	$(OCAMLC) -c $(COMMON).ml

clean:
	$(RM) -f *.cm? $(LEXER).ml
