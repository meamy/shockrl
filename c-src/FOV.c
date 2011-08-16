#include "FOV.h"

void compute_fov() {
	Actor * player = lookup_id(player_id);
	Position * pos = &(player->pos);
	Tile * tile;
	int per = (player->stats)->per, i, j;

	for (i = pos->y - per; i <= pos->y + per; i++) {
		for (j = pos->x - per; j <= pos->x + per; j++) {
			tile = get_tile(current_level, i, j);
			if (tile != NULL) {
				tile->properties = tile->properties | VISIBLE;
			}
		}
	}
}

void reset_fov() {
	Actor * player = lookup_id(player_id);
	Position * pos = &(player->pos);
	Tile * tile;
	int per = (player->stats)->per, i, j;

	for (i = pos->y - per; i <= pos->y + per; i++) {
		for (j = pos->x - per; j <= pos->x + per; j++) {
			tile = get_tile(current_level, i, j);
			if (tile != NULL) {
				tile->properties = tile->properties & ~VISIBLE;
			}
		}
	}
}
