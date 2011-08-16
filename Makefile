all:	bin

.PHONY: bin doc regression check baselines
bin: Makefile.config
	cd src && make

config: Makefile.config
	touch src/.depend
	cd ocaml-curses && make
	cd src && make depend

depend: Makefile.config
	cd src && make depend

clean: Makefile.config
	cd src && make clean

dg:
	cd src && make dg

tags:
	otags `find src/ -name "*.ml"`

configure:
	autoconf

Makefile.config: configure
	./configure
