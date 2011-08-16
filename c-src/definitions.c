#include "definitions.h"

void init_colors() {
	if (has_colors() == FALSE) {
		endwin();
		printf("No colour support, quitting...\n");
		exit(1);
	}
	start_color();
	
	init_pair(C_RED, COLOR_RED, COLOR_BLACK);
	init_pair(C_GREEN, COLOR_GREEN, COLOR_BLACK);
	init_pair(C_YELLOW, COLOR_YELLOW, COLOR_BLACK);
	init_pair(C_BLUE, COLOR_BLUE, COLOR_BLACK);
	init_pair(C_MAGENTA, COLOR_MAGENTA, COLOR_BLACK);
	init_pair(C_CYAN, COLOR_CYAN, COLOR_BLACK);
	init_pair(C_WHITE, COLOR_WHITE, COLOR_BLACK);

}
