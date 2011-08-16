#include "cmd.h"

#define MAXBIND 15
#define MAXKEYLENGTH 25
#define MAXCMDLENGTH 25

/* Keybinding pair. Pairs an integer key value
	with the command it is bound to */
typedef struct {
	unsigned int key;
	Command cmd;
} Key_map;

/* Key bindings. Initialized to default values */
static Key_map Key_bindings[MAXBIND] = {
	{KEY_LEFT,  CMD_LEFT},
	{KEY_RIGHT, CMD_RIGHT},
	{KEY_UP,    CMD_UP},
	{KEY_DOWN,  CMD_DOWN},
	{10,        CMD_ACCEPT},
	{27,        CMD_CANCEL},
	{'q',       CMD_QUIT},
	{'s',       CMD_SAVE},
	{'f',       CMD_FIRE},
	{'i',       CMD_INVENTORY},
	{'u',       CMD_USE},

	/* Vikeys */
	{'k',       CMD_UP},
	{'j',       CMD_DOWN},
	{'h',       CMD_LEFT},
	{'l',       CMD_RIGHT},
};

/*-------------------Config file definitions */
struct key_pair {
	char str[MAXKEYLENGTH];
	unsigned int key;
};
struct cmd_pair {
	char str[MAXCMDLENGTH];
	Command cmd;
};

static struct key_pair key_pairs[] = {
	{"arrow_left",  KEY_LEFT},
	{"arrow_right", KEY_RIGHT},
	{"arrow_up",    KEY_UP},
	{"arrow_down",  KEY_DOWN},
	{"escape",      27},
	{"enter",       10},
	{"q",           'q'},
	{"s",           's'},
	{"f",           'f'},
	{"i",           'i'},
	{"u",           'u'},
};
static int numkeypair = sizeof(key_pairs)/sizeof(struct key_pair);

static struct cmd_pair cmd_pairs[] = {
	{"left", 				CMD_LEFT},
	{"right",				CMD_RIGHT},
	{"up",					CMD_UP},
	{"down",				CMD_DOWN},
	{"save",				CMD_SAVE},
	{"quit",				CMD_QUIT},
	{"target/fire",	CMD_FIRE},
	{"inventory",		CMD_INVENTORY},
	{"accept",			CMD_ACCEPT},
	{"use",					CMD_USE},
	{"cancel",			CMD_CANCEL},
};
static int numcmdpair = sizeof(cmd_pairs)/sizeof(struct key_pair);
/*-------------------------------------------*/

/* Takes a keyboard input and returns the command
	that input is bound to in Key_bindings */
Command lookup_cmd(unsigned int key) {
	int i;

	for (i=0; i<MAXBIND; i++) {
		if (Key_bindings[i].key == key) {
			return Key_bindings[i].cmd;
		}
	}

	return CMD_NONE;
}

/* Simple get string function
	Can you tell I hate input handling yet? */
static void get_string(char str[], FILE *fp) {
	int ch;
	int i = 0;

	ch = getc(fp);
	while(isspace(ch)) {
		ch = getc(fp);
	}

	while(!isspace(ch)) {
		str[i++] = ch;
		ch = getc(fp);
	}
	str[i] = '\0';
}


/* Reads the keybindings defined in the file fp.
	The keybindings should start where the cursor
	currently lies and end at an [end] string */
int load_bindings(FILE *fp) {
	char str1[MAXKEYLENGTH], str2[MAXCMDLENGTH], ch;
	unsigned int key, i;
	Command cmd;

	get_string(str1, fp);
	while(strcmp(str1, "[end]") != 0) {
		get_string(str2, fp);

		/* Hackey - translate the config key to the ascii key */
		for (i=0; i<numkeypair; i++) {
			if (strncmp(str1, key_pairs[i].str, strlen(key_pairs[i].str)) == 0) {
				key = key_pairs[i].key;
				i = numkeypair;
			}
		}

		/* Hackey again - translate the config command to game command */
		for (i=0; i<numcmdpair; i++) {
			if (strncmp(str2, cmd_pairs[i].str, strlen(cmd_pairs[i].str)) == 0) {
				cmd = cmd_pairs[i].cmd;
				i = numcmdpair;
			}
		}

		/* Search the the list of keybindings and replace any binding
			to the given key with the new binding */
		for (i=0; i<MAXBIND; i++) {
			if (Key_bindings[i].key == key || Key_bindings[i].key == 0) {
				Key_bindings[i].cmd = cmd;
				i = MAXBIND;
			}
		}

		get_string(str1, fp);
	}

	return 0;
}
