objects = main.o definitions.o id.o display.o map.o game.o file.o cmd.o turn.o rand.o actor.o FOV.o

rl : $(objects)
	gcc -o rl $(objects) -lncurses

FOV.o : FOV.c
actor.o: actor.c
rand.o : rand.c
turn.o : turn.c
cmd.o : cmd.c
file.o : file.c
id.o : id.c
map.o : map.c
definitions.o : definitions.c
display.o : display.c
game.o : game.c
main.o : main.c

clean : 
	rm $(objects)
