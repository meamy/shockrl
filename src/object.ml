open Curses;;
open Util;;
open Level;;

class type virtual obj_type = object
  val virtual mutable state : char
  val virtual pos : position
  val virtual map_ref : Level.Map.t
  val virtual properties : int

  method virtual interact : Actor.actor -> unit
  method print : Curses.window -> int * int -> unit
end

class virtual obj : obj_type = object
  val virtual mutable state : char
  val virtual pos : position
	val virtual map_ref : Map.t
	val virtual properties : int

	method virtual interact : Actor.actor -> unit
	method print win (x0, y0) =
	  let ch = int_of_char state in
		  wrap (mvwaddch win (pos.y - y0) (pos.x - x0) ch);
			wrap (wnoutrefresh win)
end

class door map x y = object
  inherit obj
	val mutable state = '+'
	val pos = { x = x; y = y }
	val map_ref = map
	val properties = blocked lor opaque

	method interact _ = 
	  if state = '+' then begin
		  state <- '/';
      Tile.unset properties (Map.get_tile map_ref x y)
		end
end
