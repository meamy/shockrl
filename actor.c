#include "actor.h"

Actor_id new_actor(Actor_type type, int x, int y) {
	Actor_id actorid = new_id(TYPE_ACTOR);
	Actor * nactor = lookup_id(actorid);
	Stat_list * stats = malloc(sizeof(Stat_list));

	nactor->type = type;
	set_position(&(nactor->pos), x, y);
	nactor->hp = 0;
	nactor->pp = 0;
	stats->per = 5;

	nactor->stats = stats;

	return actorid;
}

void del_actor(Actor_id id) {
	free_id(id);
}

Position * actor_position(Actor_id actor) {
	Actor * actor_adr = lookup_id(actor);
	if (actor_adr == NULL) {
		return NULL;
	} else {
		return &(actor_adr->pos);
	}
}

Actor_type actor_gettype(Actor_id actor) {
	Actor * actor_adr = lookup_id(actor);
	if (actor_adr == NULL) {
		return 0;
	} else {
		return actor_adr->type;
	}
}
