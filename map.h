#include "id.h"
#include "item.h"

/*-----------------------Map.h-------------------------
	Defines structures and functions relating to the map
	and position, as well as macros for checking and
	manipulating properties

	A position is simply a pair of two integers, used to store
	position coordinates for actors

	Each map is a MAPHEIGHT by MAPWIDTH array of tiles,
	each of which has a type, set of properties, list of
	items, and the actor occupying it.
	Tile properties are stored in a single byte, where a bit 
	set to "1" means the tile has that bit's corresponding
	property
-----------------------------------------------------*/
	

#ifndef MAP_H
#define MAP_H

#define MAPHEIGHT 20
#define MAPWIDTH  80

#define PASSABLE 0x01
#define EXPLORED 0x01 << 1
#define SEETHROUGH 0x01 << 2
#define VISIBLE (0x01 << 3)
#define MONSTER 0x01 << 4
#define OBJECT 0x01 << 5
#define ITEM 0x01 << 6
#define ISPASSABLE(prop) (prop & 0x01)
#define ISEXPLORED(prop) ((prop >> 1) & 0x01)
#define ISSEETHROUGH(prop) ((prop >> 2) & 0x01)
#define ISVISIBLE(prop) ((prop >> 3) & 0x01)
#define HASMONSTER(prop) ((prop >> 4) & 0x01)
#define HASOBJECT(prop) ((prop >> 5) & 0x01)
#define HASITEM(prop) ((prop >> 6) & 0x01)

typedef enum {
	N,NE,E,SE,S,SW,W,NW} Direction;

/*------------------------Structure for storing locations
--------------------------------------------------------*/
typedef struct {
	int x;
	int y;
} Position;

/*-------------------------------------------Tile structure
	Contains the type of tile and its properties------------*/
typedef struct {
	char type;
	int properties;
	char color;
} Tile;

/*-------------------------------------------Map structure
	We set Actor_id and Item_id to 0 if there are no actors
	or ids on the map---------------------------------------*/
typedef struct {
	Tile tile[MAPHEIGHT][MAPWIDTH];
	List * actors;
	List * items;
} Map;

/* Sets the coordinates of a given pair */
void set_position(Position *pos, int x, int y);
int move_position(Map_id map, Position *pos, Direction dir);
/* Returns the address of the tile at the given coordinates */
Tile * get_tile(Map_id map, int i, int j);
List * get_actors(Map_id map);
List * get_items(Map_id map);

void add_actor(Map_id map, Actor_id actor);
void add_item(Map_id map, Item_id item);

#endif
