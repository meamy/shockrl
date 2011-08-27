open Level;;
open Curses;;
open Err;;

let new_game () =
	let map = Map.create () in
	let rec test () = match Cmd.lookup (getch ()) with
	  | Cmd.Cancel -> ()
		| _ -> test ()
	in
	  flushinp ();
		Display.bootstrap_hud ();
	  Display.print_map map;
		test ();
		Display.close_hud ()
