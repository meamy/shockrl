open Scanf;;

let config_file = "config.ini"

let parse ic =
  let rec parse_string str =
    if str = "[keybindings]" then
      Cmd.config ic
  let rec process () =
    try 
      fscanf ic "%s" parse_string;
      process ()
    with _ -> ()
  in
    process ()

let load_config () =
  try 
    let ic = open_in config_file in
      parse ic
  with Sys_error -> ()
