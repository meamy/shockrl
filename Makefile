all:	bin

.PHONY: bin doc regression check baselines
bin: Makefile.config
	cd src && make

regression: Makefile.config
	cd regression && make

baselines:
	cd regression && ./regression.sh baselines

check:
	cd regression && ./regression.sh run

config: Makefile.config
	touch src/.depend
	touch regression/.depend
	chmod +x cil/configure
	chmod +x ocamlgraph/configure
	chmod +x regression/regression.sh
	cd cil && ./configure && make
	cd ocamlgraph && ./configure && make
	cd src && make depend

depend: Makefile.config
	cd src && make depend
	cd regression && make depend

clean: Makefile.config
	cd src && make clean
	cd regression && make clean

doc:
	cd src && make doc

dg:
	cd src && make dg

tags:
	otags `find src/ -name "*.ml"`

ounit:
	cd ounit && make allopt

configure:
	autoconf

Makefile.config: configure
	./configure
