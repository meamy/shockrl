#include <ncurses.h>
#include "game.h"
#include "definitions.h"
#include "cmd.h"

/* Menu size */
#define WIDTH 30
#define HEIGHT 10

/* Menu options
	 String is for printing the options, function
	 array is for executing the function */
char *options[] = {
	"New Game",
	"Continue Game",
	"Instructions",
	"Credits",
	"Exit",
};
int nops = sizeof(options) / sizeof(char*);

/* Array of function pointers */
void (*f[])(void) = {
	new_game, continue_game, instructions, credits, endgame,
};

void print_title() {
	attron(COLOR_PAIR(2) | A_BOLD);
	mvprintw(3, 0, "        88888888  888  888 88888888 doooooo 888  ,dP d88:88o  888\n");
  				printw("        88ooooPp  88888888 888  888 d88     888o8P'  888888P  888\n");
  				printw("               d8 88P  888 888  888 d88     888 Y8L  88P d8   888\n");
  				printw("        8888888P  88P  888 888oo888 d888888 888  `8p 88P  48n 888PPPPP\n");
	attroff(COLOR_PAIR(2) | A_BOLD);
}

/* Menu function */
int menu() {
	int i, pos = 0;
	Command cmd;
	WINDOW *menu_win = newwin(10, 60, 10, 8);
	keypad(menu_win, TRUE);

	print_title();
	wattrset(menu_win, COLOR_PAIR(4));
	refresh();

	wclear(menu_win);
	box(menu_win, 0, 0);
	for (i = 0; i < nops; i++) {
		mvwprintw(menu_win, i+2, 2, "%s", options[i]);
	}
	mvwchgat(menu_win, pos+2, 2, WIDTH-3, A_BOLD, 2, NULL);
	wrefresh(menu_win);
	while (1) {
		cmd = lookup_cmd(wgetch(menu_win));
		switch (cmd) {
			case CMD_UP:
				if (pos != 0) {
					mvwchgat(menu_win, pos + 2, 1, WIDTH-3, A_NORMAL, 4, NULL);
					mvwchgat(menu_win, --pos+2, 1, WIDTH-3, A_BOLD, 2, NULL);
				}
				break;
			case CMD_DOWN:
				if (pos != nops-1) {
					mvwchgat(menu_win, pos + 2, 1, WIDTH-3, A_NORMAL, 4, NULL);
					mvwchgat(menu_win, ++pos+2, 1, WIDTH-3, A_BOLD, 2, NULL);
				}
				break;
			default:
				break;
		}
		if (cmd == CMD_ACCEPT) {
			wclear(menu_win);
			delwin(menu_win);
			f[pos] ();
			return pos;
		}
	}
}

/* -----------------------MAIN.C---------------*/
int main() {
	initscr();  // Start ncurses mode
	raw();      // Line buffering disabled
	keypad(stdscr, TRUE);   // get arrow keys...
	noecho();   // Don't echo character typing to the terminal
	init_colors(); // Start color functionality
	curs_set(0); // Don't show the cursor
	load_config(); /* Load configuration settings */

	int flag = 0;

	/* Loop the menu function until the player has chosen "Exit"*/
	while (flag != (nops-1)) {
		flag = menu();
	}

	clear();
	endwin();

	return 0;
}
