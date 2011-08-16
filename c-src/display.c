#include "display.h"

#define DHEIGHT 2
#define DWIDTH 80
#define HHEIGHT 2
#define HWIDTH 80

static WINDOW *dialogue_win, *map_win, *status_win;
char messages[2][81] = {"", ""};

/* Initializes the main game screen */
void init_display() {
	dialogue_win = newwin(DHEIGHT, DWIDTH, 0, 0);
	wattrset(dialogue_win, COLOR_PAIR(C_WHITE));

	map_win = newwin(MAPHEIGHT, MAPWIDTH, DHEIGHT, 0);

	status_win = newwin(HHEIGHT, HWIDTH, DHEIGHT + MAPHEIGHT, 0);
	wattrset(status_win, COLOR_PAIR(C_WHITE));
	refresh();
}

/* Clears the game screen and frees up the windows allocated*/
void end_display() {
	wclear(dialogue_win);
	wnoutrefresh(dialogue_win);
	delwin(dialogue_win);

	wclear(map_win);
	wnoutrefresh(map_win);
	delwin(map_win);

	wclear(status_win);
	wnoutrefresh(status_win);
	delwin(status_win);

	doupdate();
}

/* Adds a message to the message window */
void add_message(char msg[]) {
	if (strlen(msg) <= 80) {
		strcpy(messages[0], messages[1]);
		strcpy(messages[1], msg);
	}

	wclear(dialogue_win);
	mvwprintw(dialogue_win, 0, 0, messages[0]);
	mvwprintw(dialogue_win, 1, 0, messages[1]);
	wnoutrefresh(dialogue_win);
}

/* Reads a string while echoing it to the message window */
void read_input(char str[]) {
/*
	ch = wgetch(dialogue_win);
	while(ch != 10) {
		if (isalnum(ch)) {
			waddch(dialogue_win, ch);
			str[i] = ch;
		} else if (ch == KEY_BACKSPACE) { */

	echo();
	wgetstr(dialogue_win, str);
	noecho();
	strcat(messages[1], str);
}
			
/* Writes the map display to the virtual window without updating */
void print_map(Map_id map) {
	int i, j;
	Tile *tile;
	List *lst;
	Actor *actor;
	Position *pos;

	if (map == 0) {
		return;
	}
	for (i = 0; i <= MAPHEIGHT; i++) {
		for (j = 0; j <= MAPWIDTH; j++) {
			tile = get_tile(map, i, j);
			if (tile != NULL) {
				if (ISVISIBLE(tile->properties)) {
					wattrset(map_win, COLOR_PAIR(tile->color));
				} else {
					wattrset(map_win, COLOR_PAIR(C_GRAY) | A_BOLD);
				}
				mvwaddch(map_win, i, j, tile->type);
			}
		}
	}
	wattrset(map_win, COLOR_PAIR(C_WHITE));

	lst = get_actors(map);
	while (lst != NULL) {
		actor = lookup_id(car(lst));
		if (actor != NULL) {
			pos = &(actor->pos);
			tile = get_tile(current_level, pos->y, pos->x);
			if (ISVISIBLE(tile->properties))
			mvwaddch(map_win, pos->y, pos->x, actor->type);
		}

		lst = cdr(lst);
	}
	wnoutrefresh(map_win);
}
