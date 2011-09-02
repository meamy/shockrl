(* Interval trees *)
module Make (M : Map.OrderedType) = struct

  type interval = M.t * M.t
  type t = Leaf | Node of interval * t * t
  type dir = Left | Right

  let lt x y = (M.compare x y) <  0
  let le x y = (M.compare x y) <= 0
	let gt x y = (M.compare x y) >  0
	let ge x y = (M.compare x y) >= 0

  let empty = Leaf

  (* Add an interval to the tree, merging with any overlapping ones *)
  let rec add (min, max) itree = 
    let rec add_lr m itree dir = match itree with
      | Leaf -> (m, itree)
 	    | Node ((imin, imax), left, right) ->
	        match dir with
			      | Left -> if gt m imax then (m, itree)
				              else if ge m imin then (imin, left)
									    else add_lr m left dir
				    | Right -> if lt m imin then (m, itree)
				               else if le m imax then (imax, right)
									     else add_lr m right dir
    in
      match itree with
        | Leaf -> Node ((min, max), Leaf, Leaf)
        | Node ((imin, imax), left, right) ->
            if lt max imin then 
		          Node ((imin, imax), add (min, max) left, right)
		        else if gt min imax then
		          Node ((imin, imax), left, add (min, max) right)
		        else
		          let (new_min, new_left)  = add_lr min itree Left in
		          let (new_max, new_right) = add_lr max itree Right in
			          Node ((new_min, new_max), new_left, new_right)

  (* Test if x is a member of an interval in itree *)
  let rec mem x itree = match itree with
    | Leaf -> false
    | Node ((imin, imax), left, right) ->
        if lt x imin then mem x left
		    else if gt x imax then mem x right
		    else true
(*
  let rec string_of_itree itree = match itree with
    | Leaf -> " "
    | Node ((x, y), left, right) ->
        (string_of_itree left) ^ "(" ^ (string_of_float x) ^ "," 
		     ^ (string_of_float y) ^ ")" ^ (string_of_itree right)
*)
end
