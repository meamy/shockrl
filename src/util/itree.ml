(** Interval trees *)

type interval = float * float
type itree = Leaf | Node of interval * itree * itree

let empty = Leaf

let rec add_left min itree = match itree with
  | Leaf -> (min, itree)
	| Node ((imin, imax), left, right) ->
	    if (min > imax) then (min, itree)
	    else if (min >= imin) then (imin, left)
			else add_left min left

let rec add_right max itree = match itree with
  | Leaf -> (max, itree)
	| Node ((imin, imax), left, right) ->
	    if (max < imin) then (max, itree)
	    else if (max <= imax) then (imax, right)
			else add_left max right

let rec add (min, max) itree = match itree with
  | Leaf -> Node ((min, max), Leaf, Leaf)
	| Node ((imin, imax), left, right) ->
	    if (max < imin) then 
			  Node ((imin, imax), add (min, max) left, right)
			else if (min > imax) then
			  Node ((imin, imax), left, add (min, max) right)
			else
			  let (new_min, new_left)  = add_left min itree in
			  let (new_max, new_right) = add_right max itree in
				  Node ((new_min, new_max), new_left, new_right)

let rec mem x itree = match itree with
  | Leaf -> false
	| Node ((imin, imax), left, right) ->
	    if x < imin then mem x left
			else if x > imax then mem x right
			else true

let rec string_of_itree itree = match itree with
  | Leaf -> " "
	| Node ((x, y), left, right) ->
	    (string_of_itree left) ^ "(" ^ (string_of_float x) ^ "," 
			  ^ (string_of_float y) ^ ")" ^ (string_of_itree right)
