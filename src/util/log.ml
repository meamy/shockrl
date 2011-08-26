let debug_file = "debug.log"

let debug_channel = 
  try open_out debug_file
	with Sys_error _ -> failwith "Log: could not open file for debugging"

let debug str =
	output_string debug_channel str;
	output_char debug_channel '\n'
