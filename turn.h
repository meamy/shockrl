#include "id.h"

#ifndef TURN_H
#define TURN_H

void initialize_turns();
void wait_turn(uniqueid id, int delay);
uniqueid next_turn();
void print_turn_queue();

#endif
