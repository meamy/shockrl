open Util;;
open Curses;;

let map_width  = 80
let map_height = 20

let default_attr = A.bold lor A.color_pair Colour.gray

(* ------------------- Tile *)
module Tile : sig 
  type t

  val make     : terrain -> t
  val assign   : t -> terrain -> unit
  val place    : t -> Abstract.obj -> unit

  val is       : int -> t -> bool
  val set      : int -> t -> unit
  val unset    : int -> t -> unit

  val interact : t -> unit

  val print_look : Curses.window -> t -> int -> int -> look -> unit
  val print      : Curses.window -> t -> int -> int -> unit
end = struct
  type t = {
    mutable typ        : terrain;
    mutable look       : look;
    mutable properties : int;
    mutable obj        : Abstract.obj option }
    
  let lookup_terrain terrain = match terrain with
    | Empty  -> ((' ', A.color_pair Colour.gray), 0)
    | Floor  -> (('.', A.color_pair Colour.white), 0)
    | Wall   -> (('#', A.color_pair Colour.white), blocked lor opaque)

  (* Make a new tile with the given terrain type *)
  let make terrain = 
    let (look, prop) = lookup_terrain terrain in
    { typ = terrain; look = look; properties = prop; obj = None }
      
	(* Assign a tile to a certain terrain type *)
  let assign tile terrain =
    let (look, prop) = lookup_terrain terrain in
    tile.typ <- terrain;
    tile.look <- look;
    tile.properties <- prop

	(* Properties utilities *)
  let is prop tile    = (tile.properties land prop) != 0
  let set prop tile   = tile.properties <- tile.properties lor prop
  let unset prop tile = tile.properties <- tile.properties land (lnot prop)

	(* Place an object on a tile *)
  let place tile obj = match tile.obj with
    | None -> 
      set (obj#get_properties ()) tile;
      tile.obj <- Some obj
    | _ -> Log.debug "ERROR: tile already contains object"

	(* Interact with the object on the tile *)
  let interact tile = match tile.obj with
    | None -> ()
    | Some obj -> obj#interact ()

	(* Printing utilities *)
  let print_look win tile x y (ch, attr) =
    if (is mapped tile) then 
      begin
	begin match (is visible tile) with
	| true -> wattrset win attr
	| false -> wattrset win default_attr
	end;
        ignore (mvwaddch win y x (int_of_char ch))
      end
    else
      ignore (mvwaddch win y x (int_of_char  ' '))
  let print win tile x y = match tile.obj with
    | None -> print_look win tile x y tile.look
    | Some obj -> print_look win tile x y (obj#get_look ())
end

(* -------------------------- Map *)
module Map : sig
  type t
  type tile = Tile.t

  exception Out_of_bounds

  val create   : ?height:int -> ?width:int -> unit -> t
  val height   : t -> int
  val width    : t -> int

  val get_tile : t -> int -> int -> tile
  val print    : Curses.window -> t -> int * int -> unit
end = struct
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
    let f _ = Array.init height (fun _ -> Tile.make Floor) in
    { a = Array.init width f;
      height = height;
      width = width }
      
  let height map = map.height
  let width map = map.width

  let get_tile map x y = 
    check_bounds map x y;
    map.a.(x).(y)

  let add_obj map obj x y =
    let tile = get_tile map x y in
    Tile.place tile obj
      
  let print win map (x0, y0) = 
    for i = 0 to Config.view_width - 1 do
      for j = 0 to Config.view_height - 1 do
	Tile.print win (get_tile map (x0 + i) (y0 + j)) i j
      done
    done;
    wrap (wnoutrefresh win)
end

(*
module Map = struct
  type tile = Tile.t
  type t = {
    height : int;
    width  : int;
    a      : tile array array;
    actors : Actor list;
    objects : 
 *)   
