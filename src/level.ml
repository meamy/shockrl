open Util;;
open Curses;;

let map_width  = 80
let map_height = 20

module Tile = struct
  type t = {
    mutable typ : char;
    mutable properties : int;
	  mutable color : int }

  (* Most basic tile *)
	let unit  = { typ = ' '; properties = 0; color = Colour.gray }

	(* Terrain types and their base properties *)
	let floor = ( '.', 0, Colour.white)
	let wall  = ( '#', blocked lor opaque, Colour.white)

  let make (typ, prop, color) = { typ = typ; properties = prop; color = color }

  (* Returns a fresh copy of a tile *)
  let copy tile = 
	  { typ = tile.typ; properties = tile.properties; color = tile.color }

  (* Assign a tile to a certain terrain type *)
	let assign tile (typ, prop, color) =
	  tile.typ <- typ;
		tile.properties <- prop;
		tile.color <- color

  (* Properties utilities *)
	let is prop tile = (tile.properties land prop) != 0
	let set prop tile   = tile.properties <- tile.properties lor prop
	let unset prop tile = tile.properties <- tile.properties land (lnot prop)

	let print tile x y win =
	  if (is mapped tile) then 
		  begin
			  begin match (is visible tile) with
		      | true -> wattr_on win (A.color_pair tile.color)
			    | false -> wattr_on win (A.bold lor A.color_pair Colour.gray)
				end;
        ignore (mvwaddch win y x (int_of_char tile.typ))
		  end
		else
		  ignore (mvwaddch win y x (int_of_char  ' '))

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

  let create ?(height = map_height) ?(width = map_width) () =  
	  let f _ = Array.init height (fun _ -> Tile.make Tile.floor) in
	    { a = Array.init width f;
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
				Tile.print (get_tile map (x0 + i) (y0 + j)) i j win
			done
		done;
		wrap (wnoutrefresh win)
end
