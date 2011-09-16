open Util;;
open Curses;;

let map_width  = 80
let map_height = 20

let default_attr = A.bold lor A.color_pair Colour.gray

(* ------------------- Tile *)
module type TILE_TYPE = sig
  type t
	type terrain =
	  | Empty
		| Floor
		| Wall
	
	val copy     : t -> t
	val make     : terrain -> t
	val assign   : t -> terrain -> unit

	val is       : int -> t -> bool
	val set      : int -> t -> unit
	val unset    : int -> t -> unit

	val print    : Curses.window -> t -> int -> int -> unit
	val print_ch : Curses.window -> t -> int -> int -> int -> int -> unit
end


module Tile : Tile_type = struct
  type t = {
    mutable typ : char;
    mutable properties : int;
	  mutable attr : int }
	
	type terrain =
	  | Empty
	  | Floor
		| Wall
	
	let lookup_terrain terrain = match terrain with
	  | Empty  -> (' ', 0, A.color_pair Colour.gray)
	  | Floor  -> ('.', 0, A.color_pair Colour.white)
		| Wall   -> ('#', blocked lor opaque, A.color_pair Colour.white)

  (* Returns a fresh copy of a tile *)
  let copy tile = 
	  { typ = tile.typ; properties = tile.properties; attr = tile.attr }

	(* Terrain types and their base properties *)
  let make terrain = 
	  let (typ, prop, attr) = lookup_terrain terrain in
		  { typ = typ; properties = prop; attr = attr }
	
  (* Assign a tile to a certain terrain type *)
	let assign tile terrain =
	  let (typ, prop, attr) = lookup_terrain terrain in
	    tile.typ <- typ;
		  tile.properties <- prop;
		  tile.attr <- attr

  (* Properties utilities *)
	let is prop tile    = (tile.properties land prop) != 0
	let set prop tile   = tile.properties <- tile.properties lor prop
	let unset prop tile = tile.properties <- tile.properties land (lnot prop)

  (* Printing utilities *)
	let print_internal win tile x y ch attr =
	  let ch = match ch with
		  | None -> int_of_char tile.typ
			| Some x -> x
		in
	  let attr = match attr with
		  | None -> tile.attr
			| Some x -> x
		in
	  if (is mapped tile) then 
		  begin
			  begin match (is visible tile) with
		      | true -> wattrset win attr
			    | false -> wattrset win default_attr
				end;
        ignore (mvwaddch win y x ch)
		  end
		else
		  ignore (mvwaddch win y x (int_of_char  ' '))
	let print win tile x y = print_internal win tile x y None None
	let print_ch win tile x y ch attr = 
	  print_internal win tile x y (Some ch) (Some attr)
end

(* -------------------------- Map *)
module type MAP_TYPE = sig
  type t
	type actor
	type obj
	type item
	type tile = Tile.t

	exception Out_of_bounds

	val create   : ?height:int -> ?width:int -> unit -> t
	val height   : t -> int
	val width    : t -> int

	val get_tile : t -> int -> int -> tile
	val print    : Curses.window -> t -> int * int -> unit
end

module Map : Map_type = struct
  type tile = Tile.t
  type t = {
	  a      : tile array array;
		height : int;
		width  : int }

	exception Out_of_bounds

	let check_bounds map x y = 
	  if (x < 0 || x >= map.width) || (y <  0 || y >= map.height) then
		  raise Out_of_bounds

  let create ?(height = map_height) ?(width = map_width) () =  
	  let f _ = Array.init height (fun _ -> Tile.make Tile.Floor) in
	    { a = Array.init width f;
		    height = height;
		    width = width }
	
	let height map = map.height
	let width map = map.width

	let get_tile map x y = 
	  check_bounds map x y;
		map.a.(x).(y)
	
	let print win map (x0, y0) = 
	  for i = 0 to Config.view_width - 1 do
		  for j = 0 to Config.view_height - 1 do
				Tile.print win (get_tile map (x0 + i) (y0 + j)) i j
			done
		done;
		wrap (wnoutrefresh win)
end
