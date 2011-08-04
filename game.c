#include "game.h"
#include "rand.h"
#include "display.h"

/* ------------------------Legacy function */
Map_id new_map() {
	int i, j, h;
	Map_id newmap = new_id(TYPE_MAP);
	Map * nmap = lookup_id(newmap);
	if (newmap == 0) {
		clear();
		endwin();
		printf("Insufficient memory. press any key to terminate");
		getch();
	}
	Tile *tile;

	for (i = 0; i < MAPHEIGHT; i++) {
		for (j = 0; j < MAPWIDTH; j++) {
			tile = get_tile(newmap, i, j);
			if (i == 0 || i == MAPHEIGHT-1 || j == 0 || j == MAPWIDTH-1) {
				tile->type = '#';
				tile->properties = 0x00;
				tile->color = C_BLUE;
			} else {
				tile->type = '.';
				tile->properties = PASSABLE;
				tile->color = C_WHITE;
			}
		}
	}

	seed_rand();
	j = 2 + gen_rand() % (MAPWIDTH-4);
	h = 1 + gen_rand() % (MAPHEIGHT-2);
	for (i = 1; i < MAPHEIGHT-1; i++) {
		tile = get_tile(newmap, i, j);
		if (i == h) {
			tile->type = '+';
			tile->color = C_CYAN;
		} else {
			tile->type = '#';
			tile->color = C_BLUE;
		}
		tile->properties = 0x00;
	}

	nmap->items = NULL;
	nmap->actors = NULL;

	return newmap;
}

void new_game() {
	player_id = new_actor(player, 1, 1);
	current_level = new_map();
	Actor_id enemy_id = new_actor(hybrid, 11, 10);
	Actor_id enemy_id2 = new_actor(shotgun_hybrid, 15, 15);
	add_actor(current_level, player_id);
	add_actor(current_level, enemy_id);
	add_actor(current_level, enemy_id2);
	initialize_turns();
	wait_turn(player_id, 5);
	wait_turn(enemy_id, 6);
	wait_turn(enemy_id2, 7);
	compute_fov();
	game();
}

void continue_game() {
	int err;
	char str[15];

	printw("Enter saved game filename [14]: ");
	getstr(str);
	err = load_game(str);
	if (err == 0) {
		printw("Game loaded. Press any key to begin");
	}
	//set_position(&player_pos, 1, 1);
	getch();
	clear();
	game();
}

void instructions() {
	WINDOW *local_win = newwin(25, 80, 0, 0);
	wattrset(local_win, COLOR_PAIR(4));
	box(local_win, 0, 0);

	mvwprintw(local_win, 1, 30, "Instructions");
	mvwprintw(local_win, 3, 3, "So, You've started up the game, and want Some instructions");
	mvwprintw(local_win, 4, 3, "so you load up this sections and here they are! Enjoy the game dickwad");
	wrefresh(local_win);

	wgetch(local_win);
	wclear(local_win);
	wrefresh(local_win);
	delwin(local_win);
}


void credits() {
	WINDOW *local_win = newwin(25, 80, 0, 0);
	wattrset(local_win, COLOR_PAIR(4));
	box(local_win, 0, 0);

	mvwprintw(local_win, 1, 32, "Credits");
	mvwprintw(local_win, 10, 10, "Matthew Amy");
	wrefresh(local_win);

	wgetch(local_win);
	wclear(local_win);
	wrefresh(local_win);
	delwin(local_win);

	refresh();
}

int player_turn() {
	int err;
	char string[15];
	Command cmd;
	Position * player_pos = actor_position(player_id);
	cmd = lookup_cmd(getch());
	switch (cmd) {
		case CMD_LEFT:
			reset_fov();
			if (move_position(current_level, player_pos, W)) {
				add_message("That's a wall");
			}
			compute_fov();
			break;
		case CMD_RIGHT:
			reset_fov();
			if (move_position(current_level, player_pos, E)) {
				add_message("That's a wall");
			}
			compute_fov();
			break;
		case CMD_UP:
			reset_fov();
			if (move_position(current_level, player_pos, N)) {
				add_message("That's a wall");
			}
			compute_fov();
			break;
		case CMD_DOWN:
			reset_fov();
			if (move_position(current_level, player_pos, S)) {
				add_message("That's a wall");
			}
			compute_fov();
			break;
		case CMD_SAVE:
			add_message("Enter save file name [14]: ");
			doupdate();
			read_input(string);
			err = save_game(string);
			if (err == 0) {
				add_message("File saved successfully!");
			}
			break;
		default:
			end_display();
			return 1;
	}
	wait_turn(player_id, 2);
	return 0;
}

void computer_turn(Actor_id actor) {
	Position * pos = actor_position(actor);
	move_position(current_level, pos, E);
	wait_turn(actor, 5);
}

void game() {
	int	quit;
	Actor_id next_actor;

	init_display();
	flushinp();

	add_message("Hey there!");
	add_message("Add message seems to be working!");
	
	while (1) {
		print_map(current_level);
		doupdate();
		next_actor = next_turn();
		switch (actor_gettype(next_actor)) {
			case player:
				quit = player_turn();
				break;
			case hybrid:
				computer_turn(next_actor);
				break;
			case shotgun_hybrid:
				computer_turn(next_actor);
				break;
			default:
				break;
		}
		if (quit == 1) return;
/*		cmd = lookup_cmd(getch());
		switch (cmd) {
			case CMD_LEFT:
				if (move_position(current_level, player_pos, W)) {
					add_message("That's a wall");
				}
				break;
			case CMD_RIGHT:
				if (move_position(current_level, player_pos, E)) {
					add_message("That's a wall");
				}
				break;
			case CMD_UP:
				if (move_position(current_level, player_pos, N)) {
					add_message("That's a wall");
				}
				break;
			case CMD_DOWN:
				if (move_position(current_level, player_pos, S)) {
					add_message("That's a wall");
				}
				break;
			case CMD_SAVE:
				add_message("Enter save file name [14]: ");
				doupdate();
				read_input(string);
				err = save_game(string);
				if (err == 0) {
					add_message("File saved successfully!");
				}
				break;
			default:
				end_display();
				return;
		}*/
	}
}

void endgame() {}
