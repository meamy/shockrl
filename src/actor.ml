open Curses;;
open Util;;
open Level;;

type actor_typ =
  | Player
	| Hybrid
	| ShotgunHybrid
	| GrenadeHybrid

let lookup_actor typ = match typ with
  | Player        -> ('@', A.color_pair Colour.white)
	| Hybrid        -> ('H', A.color_pair Colour.blue)
	| ShotgunHybrid -> ('S', A.color_pair Colour.blue)
	| GrenadeHybrid -> ('G', A.color_pair Colour.green)

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
					  Tile.unset blocked (Map.get_tile map_ref pos.x pos.y);
						Tile.set blocked tile;
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
end
