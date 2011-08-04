/*--------------- Id.h----------------*/

#include <stdio.h>
#include <malloc.h>
#include <assert.h>

#ifndef ID_H
#define ID_H

/* Types for saving and loading game 
#define TYPE_MAP 	 1
#define TYPE_ITEM  2
#define TYPE_ACTOR 3   old stuff*/
typedef enum {
	TYPE_MAP = 1,
	TYPE_ITEM = 2,
	TYPE_ACTOR = 3
} Structure_type;

/* By convention, if an id field is 0, then
	the field does not refer to an object.
	This is best illustrated by the Tile
	structure in map.h. This structure has an
	actor id field which is set to 0 if there
	is no actor on that tile */
typedef int uniqueid;

/* Specific types of identifiers */
typedef uniqueid Map_id;
typedef uniqueid Actor_id;
typedef uniqueid Item_id;

uniqueid new_id(Structure_type type);
void free_id(uniqueid id);
void * lookup_id(uniqueid id);
int save_id(FILE * fp);
int load_id(FILE * fp);

/* A general list of ids */
typedef struct node {
	uniqueid id;
	struct node * next;
} List;

List *cons(uniqueid id, List *lst);
uniqueid car(List *lst);
List *cdr(List *lst);
List *list_remove(List *lst);
void list_delete(List *lst);

#endif
