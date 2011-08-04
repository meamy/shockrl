#include <string.h>
#include <ctype.h>
#include <ncurses.h>

#ifndef CMD_H
#define CMD_H

/* Defines the possible commands */
typedef enum {
	CMD_NONE,
	CMD_LEFT,
	CMD_RIGHT,
	CMD_UP,
	CMD_DOWN,
	CMD_ACCEPT,
	CMD_CANCEL,
	CMD_QUIT,
	CMD_SAVE,
	CMD_FIRE,
	CMD_INVENTORY,
	CMD_USE,
} Command;

Command lookup_cmd(unsigned int key);
int load_bindings(FILE *fp);

#endif
