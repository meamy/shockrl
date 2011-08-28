open Err;;
open Curses;;

let map_width  = 80
let map_height = 20

type direction =
  | N
	| NE
	| E
	| SE
	| S
	| SW
	| W
	| NW

type position = {
  mutable x : int;
	mutable y : int }

module Tile = struct
  type t = {
    mutable typ : char;
    mutable properties : int;
	  mutable color : int }

	(* Properties *)
  let blocked  = 0x01
  let mapped   = 0x01 lsl 1
  let opaque   = 0x01 lsl 2
  let visible  = 0x01 lsl 3

	let unit _ = {
	  typ = '.';
		properties = mapped;
		color = Colour.red }


	let is_blocked tile = (tile.properties land blocked) != 0
	let is_mapped  tile = (tile.properties land mapped)  != 0
	let is_opaque  tile = (tile.properties land opaque)  != 0
	let is_visible tile = (tile.properties land visible) != 0

	let block   tile = tile.properties <- tile.properties lor blocked
	let unblock tile = tile.properties <- tile.properties land (lnot blocked)

	let make_visible   tile = tile.properties <- tile.properties lor visible
	let make_invisible tile = tile.properties <- tile.properties land (lnot visible)

	let set_blocked tile = tile.properties <- tile.properties lor blocked
	let set_mapped tile  = tile.properties <- tile.properties lor mapped
	let set_opaque tile  = tile.properties <- tile.properties lor opaque
	let set_visible tile = tile.properties <- tile.properties lor visible

	let set_wall tile = tile.typ <- '#'

	let print tile x y win =
	  if (is_mapped tile) then begin
		  match (is_visible tile) with
		    | true -> wattr_on win (A.color_pair tile.color)
			  | false -> wattr_on win (A.color_pair Colour.white)
			end;
     try wrap (mvwaddch win y x (int_of_char tile.typ))
     with Curses_error -> ()

end

module Map : sig
  type t
	type tile = Tile.t

	exception Out_of_bounds

	val create : ?height:int -> ?width:int -> unit -> t
	val height : t -> int
	val width : t -> int
	val get_tile : t -> int -> int -> tile
	val get_position : t -> position
	val move_position : t -> direction -> unit
  val print : t -> window -> unit
end = struct
  type tile = Tile.t
  type t = {
	  a : tile array array;
		height : int;
		width  : int;
		pos    : position }

	exception Out_of_bounds

	let check_bounds map x y = 
	  if (x < 0 || x >= map.width) || (y <  0 || y >= map.height) then
		  raise Out_of_bounds

	let rec transform_pos pos dir = match dir with
	  | N ->  (pos.x,     pos.y - 1)
	  | NE -> (pos.x + 1, pos.y - 1)
		| E ->  (pos.x + 1, pos.y)
		| SE -> (pos.x + 1, pos.y + 1) 
		| S ->  (pos.x,     pos.y + 1) 
		| SW -> (pos.x - 1, pos.y + 1) 
		| W ->  (pos.x - 1, pos.y)
	  | NW -> (pos.x - 1, pos.y - 1)

  let create ?(height = map_height) ?(width = map_width) () =  {
	  a = Array.init width (fun _ -> Array.init height Tile.unit);
		height = height;
		width = width;
		pos = {x = 0; y = 0 } }
	
	let height map = map.height
	let width map = map.width

	let get_tile map x y = 
	  check_bounds map x y;
		map.a.(x).(y)
	
	let get_position map = map.pos

	let move_position map dir = 
	  let pos = map.pos in
	  let (x, y) = transform_pos pos dir in
	    try
			  let tile = get_tile map x y in
				  if Tile.is_blocked tile then ()
					else
					  Tile.unblock (get_tile map pos.x pos.y);
						Tile.block tile;
						pos.x <- x;
						pos.y <- y
			with Out_of_bounds -> ()

	let print map win = 
	  let f x y tile = Tile.print tile x y win in
	    Array.iteri (fun x a -> Array.iteri (f x) a) map.a;
			ignore (mvwaddch win map.pos.y map.pos.x (int_of_char '@'));
			wrap (wnoutrefresh win)
end
