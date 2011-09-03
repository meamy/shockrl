open Level;;
open Actor;;
open Curses;;
open Util;;

let new_game () =
	let map = Map.create ~height:40 ~width:80 () in
	let p1 = new player map 0 0 in
	let rec test () = 
	  Display.print_map map p1;
	  match Cmd.lookup (getch ()) with
	    | Cmd.Quit ->
			    let str = String.lowercase (Console.read "Exit?") in
			      if (str = "y") || (str = "yes") then ()
						else test ()
		  | Cmd.Up -> 
			    Fov.reset_fov map p1#get_pos 10;
		      p1#move N;
					Fov.calculate_fov map p1#get_pos 10;
			  	test ()
		  | Cmd.Down -> 
			    Fov.reset_fov map p1#get_pos 10;
		      p1#move S;
					Fov.calculate_fov map p1#get_pos 10;
			  	test ()
			| Cmd.Left ->
			    Fov.reset_fov map p1#get_pos 10;
			    p1#move W;
					Fov.calculate_fov map p1#get_pos 10;
					test ()
			| Cmd.Right ->
			    Fov.reset_fov map p1#get_pos 10;
			    p1#move E;
					Fov.calculate_fov map p1#get_pos 10;
					test ()
		  | _ -> test ()
	in
	  flushinp ();
		Display.bootstrap_hud ();
		Tile.assign (Map.get_tile map 20 10) Tile.wall;
		test ();
		Display.close_hud ()
