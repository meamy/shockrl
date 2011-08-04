#include "turn.h"

/* Essentially a heap data structure that serves as a turn queue 
	 Orginally the plan was to have a new queue created for each
	 level, and dynamically allocate the size based on the number
	 of enemies. However, my current theory is that if I hard code
	 the maximum number of actors on a level, I don't have to keep
	 allocating new queues. It will be more flexible to adding 
	 actors once a level has already been established */

static struct {
	int key[50];
	uniqueid id[50];
	int num;
} turn_queue;
/*
Priority_queue * pqueue_create(int maxsize) {
	Priority_queue *pqueue = malloc(sizeof(Priority_queue));
	if (pqueue == NULL) {
		return NULL;
	}
	pqueue->num = 0;

	pqueue->key = malloc(maxsize * sizeof(int));
	pqueue->id = malloc(maxsize * sizeof(uniqueid));

	return pqueue;
} */

void initialize_turns() {
	int i;

	for (i = 0; i < 50; i++) {
		turn_queue.id[i] = 0;
		turn_queue.key[i] = 0;
	}
	turn_queue.num = 0;
}

/*inserts to end of the array, performing bubble-up at the same time*/
void wait_turn(uniqueid id, int delay) {

	int i, p, temp;
	int * ids = turn_queue.id;
	int * keys = turn_queue.key;
	int * num = &(turn_queue.num);

	ids[*num] = id;
	keys[*num] = delay;
	(*num)++;

	//bubble-up from last element added
	i = *num;
	while(1) {
		p = i/2;
		//if parent exists and key[parent] > key[i]
		if ((p>0) && (keys[p-1] > keys[i-1])) {
			temp = keys[i-1];
			keys[i-1] = keys[p-1];
			keys[p-1] = temp;

			temp = ids[i-1];
			ids[i-1] = ids[p-1];
			ids[p-1] = temp;

			i = p;
		} else {
			break;
		}
	}
}


//iterates through the heap, printing out its elements
void print_turn_queue() {
	int i;
	for (i=0; i<turn_queue.num; i++) {
		fprintf(stderr, "%d: %d\n", turn_queue.key[i], turn_queue.id[i]);
	}
}

//bubble-down, at node i (array element i-1)
void bubble_down(int i) {
	int j, k, m, temp;
	int * ids = turn_queue.id;
	int * keys = turn_queue.key;
	int * num = &(turn_queue.num);
	uniqueid tmp;

	while(*num >= 2*i) {
		j = 2*i;

		//checks if child at (2*i + 1) exists
		if (*num >= 2*i + 1)
			k = 2*i + 1; 
		else
			k = i;

		//finds the minimum of node i's children
		if (keys[j-1] <= keys[k-1]) {
			m = j;
		} else {
			m = k;
		}

		if (keys[i-1] > keys[m-1]) {
			temp = keys[i-1];
			keys[i-1] = keys[m-1];
			keys[m-1] = temp;

			tmp = ids[i-1];
			ids[i-1] = ids[m-1];
			ids[m-1] = tmp;

			i = m;
		} else { 
			break;
		}
	}
}

/*extracts the minimum element of the heap, bubbles down
  to maintain the heap quality, then returns the min element */
uniqueid next_turn() {
	int i = 0, key;

	uniqueid ret = turn_queue.id[0];
	key = turn_queue.key[0];
	turn_queue.key[0] = turn_queue.key[turn_queue.num - 1];
	turn_queue.id[0] = turn_queue.id[turn_queue.num - 1];
	turn_queue.num--;
	bubble_down(1);

	while(turn_queue.id[i] != 0) {
		turn_queue.key[i] = turn_queue.key[i] - key;
		i++;
	}

	return ret;
}
