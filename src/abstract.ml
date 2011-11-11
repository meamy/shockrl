(* Abstract map objects. Define the functions visible to the map *)

open Curses;;
open Util;;

class virtual actor = object
  method virtual do_turn : unit -> int
end

class virtual obj = object
  method virtual interact : unit -> unit
	method virtual get_look : unit -> look
	method virtual get_properties : unit -> int
end
