#include "rand.h"
#include <stdlib.h>
#include <time.h>

void seed_rand() {
	srand(time(NULL));
}

int gen_rand() {
	return rand();
}
