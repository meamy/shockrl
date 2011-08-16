#include "id.h"
#include "map.h"
#include "item.h"
#include "actor.h"
#include "game.h"

#define SIZE 100

/* static ID counter. Used to obtain a
  new unique id */
static ID = 1;

/* static array to store memory addresses, accessed by ID number */
static void * IDlist[100] = {NULL};
static Structure_type IDtype[100] = {0}; 

/* Kind of unecessary, but I thought I'd make this
	a seperate function to enhance readability. Considering
	making this a macro, or some way to make this automatic */
size_t sizeof_type(Structure_type type) {
	if (type == TYPE_MAP) return sizeof(Map);
	if (type == TYPE_ITEM) return sizeof(Item);
	if (type == TYPE_ACTOR) return sizeof(Actor);
	return 0;
}

/* Allocates (size) space on the heap and assigns the
	current ID number to that address */
uniqueid new_id(Structure_type type) {
	uniqueid new = ID++;
	IDlist[new] = malloc(sizeof_type(type));
	if (IDlist[new] == NULL) {
		return 0;
	} else {
		IDtype[new] = type;
		return new;
	}
}

/* Assigns the given unique id to the NULL address
	and frees the allocated space*/
void free_id(uniqueid id) {
	assert(id < ID);
	free(IDlist[id]);
	IDlist[id] = NULL;
}

/* Returns the memory address the given id refers to
	If the unique id is invalid, simply returns NULL */
void * lookup_id(uniqueid id) {
	assert(id < ID);
	return IDlist[id];
}

/* Dumps the list of ids and their contents to the file
	pointed to by fp */
int save_id(FILE * fp) {
	int i;

	for(i = 1; i < ID; i++) {
		if (IDlist[i] != NULL) {
			fprintf(fp, "%d %d ", i, IDtype[i]);
			fwrite(IDlist[i], sizeof_type(IDtype[i]), 1, fp); 
			putc('\n', fp);

			if (ferror(fp) != 0) {
				return 2;
			}
		}
	}

	return 0;
}

/* Retrieves all ids and their contents from the file pointed
	to by fp, and reallocates space for them on the heap */
int load_id(FILE * fp) {
	int id;
	Structure_type type;

//	while (!feof(fp)) {
		fscanf(fp, "%d", &id);
		fscanf(fp, "%u", &type);
		getc(fp);

		IDlist[id] = malloc(sizeof_type(type));
		IDtype[id] = type;
		ID = id + 1;
		fread(IDlist[id], sizeof_type(type), 1, fp);
//	}
	current_level = 1;
	return 0;
}

/* Id list functions */

List *cons(uniqueid id, List *lst) {
	List *new = malloc(sizeof(List));
	if (new == NULL) {
		clear();
		endwin();
		printf("ERROR: Unable to allocated required memory.\n",
						"Press any key to terminate\n");
		getch();
		exit(1);
	}

	new->id = id;
	new->next = lst;

	return new;
}

uniqueid car(List *lst) {
	if (lst == NULL) {
		return -1;
	} else {
		return lst->id;
	}
}

List *cdr(List *lst) {
	if (lst == NULL) {
		return NULL;
	} else {
		return lst->next;
	}
}

List *list_remove(List *lst) {
	List *ret = cdr(lst);
	free(lst);

	return ret;
}

void list_delete(List *lst) {
	List *temp;
	while (lst) {
		temp = lst;
		lst = lst->next;
		free(temp);
	}
}

