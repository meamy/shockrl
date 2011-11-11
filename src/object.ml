open Curses;;
open Util;;
open Level;;

type obj_typ =
  | Door

let lookup_obj typ = match typ with
  | Door -> (('+', A.color_pair Colour.yellow), blocked lor opaque)

class virtual obj = object
  inherit Abstract.obj
	val virtual typ : obj_typ
	val virtual mutable look : look
  val virtual pos : position
  val virtual mutable properties : int
  val virtual map_ref : Map.t

  method virtual interact : unit -> unit
  method print win (x0, y0) =
	  let tile = Map.get_tile map_ref pos.x pos.y in
	    Tile.print_look win tile (pos.x - x0) (pos.y - y0) look;
		  wrap (wnoutrefresh win)

	method get_look () = look
	method get_properties () = properties
end

class door map x y = object (s)
  inherit obj
	val typ = Door
	val mutable look = ('+', A.color_pair Colour.yellow)
  val pos = { x = x; y = y }
  val mutable properties = blocked lor opaque
  val map_ref = map

	method open_door () =
	  let (state, attr) = look in
      if state = '+' then begin
	      look <- ('/', attr);
        Tile.unset properties (Map.get_tile map_ref x y)
	    end
	
	method close_door () =
	  let (state, attr) = look in
      if state = '/' then begin
	      look <- ('+', attr);
        Tile.set properties (Map.get_tile map_ref x y)
	    end

  method interact = s#open_door

  initializer
    Tile.set properties (Map.get_tile map_ref x y)
end
