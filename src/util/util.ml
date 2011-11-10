(* Utilities, common for all code *)

(* Exceptions *)
exception Curses_error

(* Types *)
type position = {
  mutable x : int;
	mutable y : int }

type direction =
  | N
	| NE
	| E
	| SE
	| S
	| SW
	| W
	| NW

type terrain =
  | Empty
	| Floor
	| Wall

type look = char * int

(* Properties *)
let blocked  = 0x01
let mapped   = 0x01 lsl 1
let opaque   = 0x01 lsl 2
let visible  = 0x01 lsl 3
let occupied = 0x01 lsl 4
let covered  = 0x01 lsl 5

(* Wrap curses commands to produce an exeception on error *)
let wrap b = match b with
  | true -> ()
  | false -> raise Curses_error

let get_coords x y dir = match dir with
  | N ->  (x,     y - 1)
  | NE -> (x + 1, y - 1)
	| E ->  (x + 1, y)
	| SE -> (x + 1, y + 1) 
	| S ->  (x,     y + 1) 
	| SW -> (x - 1, y + 1) 
	| W ->  (x - 1, y)
  | NW -> (x - 1, y - 1)
