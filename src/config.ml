open Scanf;;

let debug = ref true

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
