open Scanf;;

let debug = ref true
let log_size = ref 100

let dialogue_height = 2
let dialogue_width  = 80
let view_height     = 20
let view_width      = 80
let status_height   = 2
let status_width    = 80

let config_file = "config.ini"

let parse ic =
  let rec process str = match str with
	  | "[keybindings]" ->
		  Log.debug "Config: Loading keybindings...";
		  Cmd.load_bindings ic;
			Log.debug "Config: Keybindings loaded";
			fscanf ic "%s" process
	  | "" -> Log.debug "Config: Configuration complete"
		| _ -> fscanf ic "%s" process
	in
    fscanf ic "%s" process

let load_config () =
  try 
    let ic = open_in config_file in
		  Log.debug "Config: Reading configuration...";
      parse ic
  with Sys_error _ -> Log.debug "Config: Could not open config.ini"
