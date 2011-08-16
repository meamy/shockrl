#include "map.h"

void set_position(Position *pos, int x, int y) {
	pos->x = x;
	pos->y = y;
}

int move_position(Map_id map, Position *pos, Direction dir) {
	int x, y;
	Tile *tile;
	x = pos->x;
	y = pos->y;

	switch (dir) {
		case N:
			y--;
			break;
		case NE:
			x++;
			y--;
			break;
		case E:
			x++;
			break;
		case SE:
			x++;
			y++;
			break;
		case S:
			y++;
			break;
		case SW:
			x--;
			y++;
			break;
		case W:
			x--;
			break;
		case NW:
			x--;
			y--;
			break;
	}

	tile = get_tile(map, y, x);
	if (ISPASSABLE(tile->properties)) {
		tile->properties = tile->properties & ~PASSABLE;
		tile = get_tile(map, pos->y, pos->x);
		tile->properties = tile->properties | PASSABLE;
		set_position(pos, x, y);
		return 0;
	} else if (tile->type == '+') {
		tile->type = '/';
		tile->properties = tile->properties | PASSABLE;
		return 0;
	} else if (tile->type == '#') {
		return 1;
	} else {
		return 0;
	}
}

Tile * get_tile(Map_id map, int i, int j) {
	Map *map_adr = lookup_id(map);
	if (map_adr == NULL || i < 0 || i > MAPHEIGHT || j < 0 || j > MAPWIDTH) {
		return NULL;
	} else {
		return &(map_adr->tile[i][j]);
	}
}

List * get_actors(Map_id map) {
	Map *map_adr = lookup_id(map);
	if (map_adr == NULL) {
		return NULL;
	} else {
		return map_adr->actors;
	}
}

List * get_items(Map_id map) {
	Map *map_adr = lookup_id(map);
	if (map_adr == NULL) {
		return NULL;
	} else {
		return map_adr->items;
	}
}

void add_actor(Map_id map, Actor_id actor) {
	Map * map_adr = (Map *)lookup_id(map);
	Position * pos = (Position *)actor_position(actor);
	Tile * tile;
	if (map_adr != NULL && pos != NULL) {
		map_adr->actors = cons(actor, map_adr->actors);
		tile = get_tile(map, pos->y, pos->x);
		if (tile != NULL) {
			tile->properties = tile->properties & !PASSABLE;
		}
	}
}
	
void add_item(Map_id map, Item_id item) {
	Map * map_adr = lookup_id(map);
	if (map_adr != NULL) 
		map_adr->items = cons(item, map_adr->items);
}
