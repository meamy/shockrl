#include <ncurses.h>
#include "map.h"
#include "file.h"
#include "cmd.h"
#include "actor.h"

#ifndef GAME_H
#define GAME_H

Map_id current_level;
Actor_id player_id; 

void new_game();
void continue_game();
void instructions();
void credits();
void game();
void endgame();

#endif
