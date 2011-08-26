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

	let unit = {
	  typ = '.';
		properties = mapped lor visible;
		color = Colour.white }


	let is_blocked tile = (tile.properties land blocked) != 0
	let is_mapped  tile = (tile.properties land mapped)  != 0
	let is_opaque  tile = (tile.properties land opaque)  != 0
	let is_visible tile = (tile.properties land visible) != 0

	let set_blocked tile = tile.properties <- tile.properties lor blocked
	let set_mapped tile  = tile.properties <- tile.properties lor mapped
	let set_opaque tile  = tile.properties <- tile.properties lor opaque
	let set_visible tile = tile.properties <- tile.properties lor visible

	let print tile x y win =
	  if (is_mapped tile) then begin
		  match (is_visible tile) with
		    | true -> wattr_on win (A.color_pair tile.color)
			  | false -> wattr_on win (A.color_pair Colour.white)
			end;
			wrap (mvwaddch win y x (int_of_char tile.typ))

end

module Map : sig
  type t
	type tile = Tile.t

	exception Out_of_bounds

	val create : ?height:int -> ?width:int -> unit -> t
	val get_tile : t -> int -> int -> tile
  val print : t -> window -> unit
end = struct
  type tile = Tile.t
  type t = {
	  a : tile array array;
		height : int;
		width : int }

	exception Out_of_bounds

	let check_bounds map x y = 
	  if (x < 0 || x >= map.width) || (y <  0 || y >= map.height) then
		  raise Out_of_bounds

  let create ?(height = map_height) ?(width = map_width) () =  {
	  a = Array.make_matrix width height Tile.unit;
		height = height;
		width = width }
	let get_tile map x y = 
	  check_bounds map x y;
		map.a.(x).(y)
	let print map win = 
	  let f x y tile = Tile.print tile x y win in
	    Array.iteri (fun x a -> Array.iteri (f x) a) map.a;
			wrap (wnoutrefresh win)
end
