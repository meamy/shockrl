#include <ncurses.h>
#include <string.h>
#include "map.h"
#include "definitions.h"
#include "game.h"

#ifndef DISPLAY
#define DISPLAY

void init_display();
void end_display();
void add_message(char msg[]);
void read_input(char str[]);
void print_map(Map_id map);

#endif
