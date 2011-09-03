open Curses;;
open Util;;
open Level;;

type actor_typ =
  | Player
	| Hybrid
	| ShotgunHybrid
	| GrenadeHybrid

let get_char typ = match typ with
  | Player        -> '@'
	| Hybrid        -> 'H'
	| ShotgunHybrid -> 'S'
	| GrenadeHybrid -> 'G'

class virtual actor = object
  val virtual typ : actor_typ
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
					end
			with Map.Out_of_bounds -> ()

	method print win (x0, y0) =
	  let ch = int_of_char (get_char typ) in
		  wrap (mvwaddch win (pos.y - y0) (pos.x - x0) ch);
			wrap (wnoutrefresh win)

end

class player map x y = object (s)
  inherit actor
	val typ = Player
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
			  

	method fov () = Fov.calculate_fov map pos 8
end
