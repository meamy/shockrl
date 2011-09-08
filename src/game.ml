open Level;;
open Actor;;
open Object;;
open Curses;;
open Util;;

let new_game () =
	let map = Map.create ~height:40 ~width:80 () in
	let p1 = new player map 0 0 in
	let d1 = new door map 21 10 in
	let rec test () = 
	  Display.print_map map p1 (d1::[]);
	  match Cmd.lookup (getch ()) with
	    | Cmd.Quit ->
			    let str = String.lowercase (Console.read "Exit?") in
			      if (str = "y") || (str = "yes") then ()
						else test ()
		  | Cmd.Up -> 
		      p1#move N;
			  	test ()
		  | Cmd.Down -> 
		      p1#move S;
			  	test ()
			| Cmd.Left ->
			    p1#move W;
					test ()
			| Cmd.Right ->
			    p1#move E;
					test ()
		  | _ -> test ()
	in
	  flushinp ();
		Display.bootstrap_hud ();
		Tile.assign (Map.get_tile map 20 10) Tile.Wall;
		p1#reset_fov ();
		p1#set_fov ();
		test ();
		Display.close_hud ()
