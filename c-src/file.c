#include "file.h"

int save_game(char filename[]) {
	FILE *fp;
	int err = 0;

	if ((fp = fopen(filename, "w")) != NULL) {
		err = save_id(fp);
	} else {
		err = 1;
	}

	fclose(fp);
	return err;
}

int load_game(char filename[]) {
	FILE *fp;
	int err = 0;

	if ((fp = fopen(filename, "r")) != NULL) {
		err = load_id(fp);
	} else {
		err = 1;
	}

	fclose(fp);
	return err;
}

int load_config() {
	FILE *fp;
	int err = 0;
	char str[25];

	if ((fp = fopen("config.ini", "r")) != NULL) {
		fgets(str, 25, fp);
		if (strncmp(str, "[keybindings]", 13) == 0) {
			err = load_bindings(fp);
		}
	} else {
		err = 1;
	}

	fclose(fp);
	return err;
}
