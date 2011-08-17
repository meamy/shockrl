open Scanf;;
open Curses;;

(* Commands in the internal representation *)
type command =
  | None
  | Left
  | Right
  | Up
  | Down
  | Accept
  | Cancel
  | Quit
  | Save
  | Attack
  | Inventory
  | Use

module HT = Hashtbl.Make(struct
                           type t = int
                           let equal = (=)
                           let hash = Hashtbl.hash
                         end)
(* Stores the set of key mappings *)
let key_map = HT.create 32
              
(* Lookup a keypress from curses "getch" *)
let lookup key =
  try HT.find key_map key
  with Not_found -> None

let lookup_key str = match str with
  | "arrow_left"  -> Key.left
	| "arrow_right" -> Key.right
	| "arrow_up"    -> Key.up
	| "arrow_down"  -> Key.down
	| "escape"      -> 27
	| "enter"       -> 10
	| _             -> 
	  if String.length str > 1 then
		  raise Not_found
		else 
	    int_of_char (str.[0])

let lookup_cmd str = match str with
  | "left" -> Left
	| "right" -> Right
	| "up"    -> Up
	| "down"  -> Down
	| "save"   -> Save
	| "quit"   -> Quit
	| "attack" -> Attack
	| "use"    -> Use
	| "inventory" -> Inventory
	| "accept"    -> Accept
	| "cancel"    -> Cancel
	| _           -> raise Not_found


(* Default keybindings, incase the config file is missing *)
let load_defaults () = 
  let defaults = [
    (Key.left, Left);
    (Key.right, Right);
    (Key.up, Up);
    (Key.down, Down);
    (10, Accept);
    (27, Cancel);
    (int_of_char 'q', Quit);
    (int_of_char 's', Save);
    (int_of_char 'f', Attack);
    (int_of_char 'i', Inventory);
    (int_of_char 'u', Use);

    (* Vikeys *)
    (int_of_char 'k', Up);
    (int_of_char 'j', Down);
    (int_of_char 'h', Left);
    (int_of_char 'l', Right)]
  in
    List.iter (fun (key, cmd) -> HT.add key_map key cmd) defaults

(* Loads the keybindings *)
let load_bindings ic =
  let parse_pair str1 str2 = begin
      try HT.add key_map (lookup_key str1) (lookup_cmd str2)
      with Not_found -> ()
    end
  in
  let rec parse_string str = 
    if str = "[end]" then ()
    else begin 
		  fscanf ic "%s" (parse_pair str);
      fscanf ic "%s" parse_string
		end
	in
	  fscanf ic "%s" parse_string
