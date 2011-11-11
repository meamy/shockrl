open Curses;;
open Util;;
open Level;;

type actor_typ =
  | Player
	| Hybrid
	| ShotgunHybrid
	| GrenadeHybrid
	| Trigger

let lookup_actor typ = match typ with
  | Player        -> ('@', A.color_pair Colour.white)
	| Hybrid        -> ('H', A.color_pair Colour.blue)
	| ShotgunHybrid -> ('S', A.color_pair Colour.blue)
	| GrenadeHybrid -> ('G', A.color_pair Colour.green)
	| Trigger       -> ('0', 0)

class virtual actor = object
  inherit Abstract.actor
  val virtual typ : actor_typ
	val virtual mutable look : look
  val virtual pos : position
	val virtual mutable map_ref : Map.t

	method get_pos = pos

	method move dir =
	  let (x, y) =  get_coords pos.x pos.y dir in
		  try
			  let tile = Map.get_tile map_ref x y in
				  if Tile.is blocked tile then ()
					else begin
					  Tile.unset (blocked lor occupied) (Map.get_tile map_ref pos.x pos.y);
						Tile.set (blocked lor occupied) tile;
						pos.x <- x;
						pos.y <- y
					end;
				  Tile.interact tile
			with Map.Out_of_bounds -> ()

	method print win (x0, y0) =
		let tile = Map.get_tile map_ref pos.x pos.y in
		  Tile.print_look win tile (pos.x - x0) (pos.y - y0) look;
			ignore (wnoutrefresh win)

end

class trigger map x y r active inactive = object
  inherit actor
	val typ = Trigger
	val mutable look = ('0', 0)
	val pos = { x = x; y = y }
	val mutable map_ref = map

	method print win (x0, y0) = ()

	method do_turn () = 
	  let (state, attr) = look in
	  let row = number_list (max (pos.x - r) 0) (min (pos.x + r) (Map.width map_ref - 1)) in
	  let col = number_list (max (pos.y - r) 0) (min (pos.y + r) (Map.height map_ref - 1)) in
		let do_tile i j = 
			if (sqrt ((float_of_int (pos.x - i))**2. +. (float_of_int (pos.y - j))**2.)) 
			    <= (float_of_int r) then
				if (Tile.is occupied (Map.get_tile map_ref i j)) then true
				else false
			else false
		in
		let fold_col flg i = List.fold_left (fun flg j -> (flg || do_tile i j)) flg col in
		let flg = List.fold_left fold_col false row in 
		  begin 
		    match (flg, state) with
		      | (true, '0') -> 
						  look <- ('1', attr);
			        active ()
				  | (false, '1') ->
				      look <- ('0', attr);
						  inactive ()
				  | _ -> ()
		  end;
			5

end

class player map x y = object (s)
  inherit actor as super
	val typ = Player
	val mutable look = ('@', A.color_pair Colour.white)
	val pos = { x = x; y = y }
	val mutable map_ref = map

	method view_offset () =
	  let get_low_coord i mn mx low high =
		  if i - low < 0 then 0
		  else if i + high > mx then mx - (low + high)
			else begin Log.debug (string_of_int (i - low)); i - low end
		in
		let wd = Config.view_width / 2 in
		let ht = Config.view_height / 2 in
		  (get_low_coord pos.x 0 (Map.width  map_ref - 1) wd (Config.view_width  - wd - 1),
		   get_low_coord pos.y 0 (Map.height map_ref - 1) ht (Config.view_height - ht - 1))
	
  method reset_fov () = Fov.reset_fov map_ref pos 8
	method set_fov ()   = ignore (Fov.set_fov map_ref pos 8)

	method update_map () =
	  let off = s#view_offset () in
		if !Display.view_win = null_window then
		  failwith "HUD not initialized";
		s#reset_fov ();
		s#set_fov ();
		try Map.print !Display.view_win map_ref off;
		    s#print !Display.view_win off
		with Curses_error -> failwith "Error displaying map"

	method print_los win (x0, y0) (x, y) =
	  let los = Fov.los (pos.x, pos.y) (x, y) in
		let rec f lst = match lst with
		  | [] -> ()
			| (x, y)::tl ->
			  ignore (mvwaddch win (y - y0) (x - x0) (int_of_char '*'));
				f tl
		in
		  f los;
			ignore (wrefresh win)

	method move dir =
	  s#reset_fov ();
		super#move dir;
		s#set_fov ()

  method do_turn () = match Cmd.lookup (getch ()) with
	  | Cmd.Quit ->
		    let str = String.lowercase (Console.read "Exit?") in
			    if (str = "y") || (str = "yes") then -1
					else 0
		| Cmd.Up -> 
		    s#move N;
				5
		| Cmd.Down -> 
		    s#move S;
				5
		| Cmd.Left ->
		    s#move W;
				5
		| Cmd.Right ->
		    s#move E;
				5
	  | _ -> 0
end
