#include "id.h"
#include "map.h"

#ifndef ACTOR_H
#define ACTOR_H

/*Let's see if I get this right
	So, we have an enumerated set of actor types
	where each type's number corresponds to the character
	that represents them on the map.

	The stat list structure includes a set of stats that
	apply to each actor. The theory at this point is that
	I'll have one structure for each type of actor and then
	when an actor is created, the appropriate stat list will
	be linked in to their structure

	The actor structure includes the type, position, current hp and pp
	as well as a link to their set of stats. The current debate is
	whether to include a list of items within the actor structure
*/
	

typedef enum {
	player = '@',
	hybrid = 'H',
	shotgun_hybrid = 'S',
	Grenade_hybrid = 'G'
} Actor_type;

typedef struct {
	int max_hp;
	int max_pp;

	int str;
	int end;
	int agi;
	int cyb;
	int psi;

	int per;
} Stat_list;

typedef struct {
	Actor_type type;
	Position pos;
	int hp;
	int pp;
	Stat_list * stats;
} Actor;

/* Functions */

Actor_id new_actor(Actor_type type, int x, int y);
void del_actor(Actor_id);
Position * actor_position(Actor_id actor);
Actor_type actor_gettype(Actor_id actor);

#endif
