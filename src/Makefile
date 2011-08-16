all: rl

ROOT=..
EXTRA_SRC = rl.ml
EXTRA_DIRS =
include $(ROOT)/Makefile.include

rl: $(OBJS_CMX) rl.cmx
	$(OCAMLOPT) $(LINK_FLAGS) -o rl $(LIBS) $^

clean:
	(for d in $(SRC_DIRS); do \
	 rm -f $$d/*.cm[iox] $$d/*.o; \
	 done)
