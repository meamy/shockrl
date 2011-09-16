open Curses;;
open Util;;
open Level;;

module type OBJ_TYPE = sig
  type map
  class type virtual obj_type = object
    val virtual mutable state : char
    val virtual pos : position
    val virtual map_ref : map
    val virtual properties : int
	  val virtual mutable attr : int

    method virtual interact : Actor.actor -> unit
    method print : Curses.window -> int * int -> unit
  end

	class obj : obj_type
end

module Make ( Map : MAP_TYPE ) : (OBJ_TYPE with map = Map.t) = struct
  type map = Map.t
  class type virtual obj_type = object
    val virtual mutable state : char
    val virtual pos : position
    val virtual map_ref : map
    val virtual properties : int
	  val virtual mutable attr : int

    method virtual interact : Actor.actor -> unit
    method print : Curses.window -> int * int -> unit
  end

  class virtual obj : obj_type = object
    val virtual mutable state : char
    val virtual pos : position
	  val virtual map_ref : map
	  val virtual properties : int
	  val virtual mutable attr : int

	  method virtual interact : Actor.actor -> unit
	  method print win (x0, y0) =
	    let ch = int_of_char state in
		  let tile = Map.get_tile map_ref pos.x pos.y in
		    Tile.print_ch win tile (pos.x - x0) (pos.y - y0) ch attr;
			  wrap (wnoutrefresh win)
  end

  class door map x y = object
    inherit obj
	  val mutable state = '+'
	  val pos = { x = x; y = y }
	  val map_ref = map
	  val properties = blocked lor opaque
	  val mutable attr = A.color_pair Colour.yellow

	  method interact _ = 
	    if state = '+' then begin
		    state <- '/';
        Tile.unset properties (Map.get_tile map_ref x y)
		  end
	
	  initializer
	    Tile.set properties (Map.get_tile map_ref x y)
  end
end
