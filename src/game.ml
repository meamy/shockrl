open Level;;
open Curses;;
open Err;;

let new_game () =
	let map = Map.create () in
	let rec test () = 
	  Display.print_map map;
	  match Cmd.lookup (getch ()) with
	    | Cmd.Cancel -> ()
		  | Cmd.Up -> 
			    Fov.reset_fov map (Map.get_position map) 10;
		      Map.move_position map N;
					Fov.calculate_fov map (Map.get_position map) 10;
			  	test ()
		  | Cmd.Down -> 
			    Fov.reset_fov map (Map.get_position map) 10;
		      Map.move_position map S;
					Fov.calculate_fov map (Map.get_position map) 10;
			  	test ()
			| Cmd.Left ->
			    Fov.reset_fov map (Map.get_position map) 10;
			    Map.move_position map W;
					Fov.calculate_fov map (Map.get_position map) 10;
					test ()
			| Cmd.Right ->
			    Fov.reset_fov map (Map.get_position map) 10;
			    Map.move_position map E;
					Fov.calculate_fov map (Map.get_position map) 10;
					test ()
		  | _ -> test ()
	in
	  flushinp ();
		Display.bootstrap_hud ();
		Tile.set_wall (Map.get_tile map 20 10);
		Tile.set_opaque (Map.get_tile map 20 10);
		test ();
		Display.close_hud ()
