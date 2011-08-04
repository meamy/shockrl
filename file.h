#include <stdio.h>
#include <string.h>
#include "id.h"

#ifndef FILE_H
#define FILE_H

int save_game(char filename[]);
int load_game(char filename[]);
int load_config();

#endif
