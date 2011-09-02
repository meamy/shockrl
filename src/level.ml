open Util;;
open Curses;;

let map_width  = 80
let map_height = 20

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
  val print : t -> window -> (int * int) -> unit
end = struct
  type tile = Tile.t
  type t = {
	  a : tile array array;
		height : int;
		width  : int }

	exception Out_of_bounds

	let check_bounds map x y = 
	  if (x < 0 || x >= map.width) || (y <  0 || y >= map.height) then
		  raise Out_of_bounds

  let create ?(height = map_height) ?(width = map_width) () =  {
	  a = Array.init width (fun _ -> Array.init height Tile.unit);
		height = height;
		width = width }
	
	let height map = map.height
	let width map = map.width

	let get_tile map x y = 
	  check_bounds map x y;
		map.a.(x).(y)
	
	let print map win (x0, y0) = 
	  for i = 0 to Config.view_width - 1 do
		  for j = 0 to Config.view_height - 1 do
		    Log.debug ((string_of_int (x0 + i)) ^ (string_of_int (y0 + j)));
				Tile.print (get_tile map (x0 + i) (y0 + j)) i j win
			done
		done;
		wrap (wnoutrefresh win)
end
