MAKE = make

.PHONY: all test clean

all:
	$(MAKE) -C src

test: all
	$(MAKE) -C test test

clean:
	$(MAKE) -C src  clean
	$(MAKE) -C test clean
