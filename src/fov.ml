open Util;;
open Level;;

module Itree = Itree.Make(struct
                            type t = float
														let compare = compare
													end)

(* Enumerate a list of numbers from low to high *)
let number_list low high =
  let rec acc low high lst = match low <= high with
	  | true -> acc low (high - 1) (high::lst)
		| false -> lst
	in
	  acc low high []

(* Produce a line from (x, y) to (u, v) *)
let los (x0, y0) (x1, y1) =
  let (dx, dy) = (abs (x1 - x0), abs (y1 - y0)) in
	let sx = if x0 < x1 then 1 else -1 in
	let sy = if y0 < y1 then 1 else -1 in
	let rec fold x0 y0 err lst =
	  if (x0 = x1) && (y0 = y1) then
		  (x0, y0)::lst
		else
			let e2 = 2 * err in
			let cx = if e2 > -dy then 1 else 0 in
			let cy = if e2 < dx then 1 else 0 in
			  fold (x0 + cx*sx) (y0 + cy*sy) (err - cx*dy + cy*dx) ((x0, y0)::lst)
	in
	  fold x0 y0 (dx - dy) []

(* Instead of iterating the whole map and setting not visible,
   only do the squares that could have possibly been visible *)
let reset_fov map pos draw_dist =
  for i = max 0 (pos.x - draw_dist) to 
	    min (Map.width map - 1) (pos.x + draw_dist) do
	  for j = max 0 (pos.y - draw_dist) to 
		    min (Map.height map - 1) (pos.y + draw_dist) do
		  Tile.unset visible (Map.get_tile map i j)
		done
	done 

(* Cross between precise shadowcasting and permissive fov *)
let set_fov map pos draw_dist = 
  let x_0 = (float_of_int pos.x) +. 0.5 in
	let y_0 = (float_of_int pos.y) +. 0.5 in

  let do_it itree dir x y =
	  let tile = Map.get_tile map x y in
		let (x, y) = (float_of_int x, float_of_int y) in
	  let (x1, y1) = (x -. x_0, y -. y_0) in
		let (x2, y2) = (x1 +. 0.5, y1 +. 0.5) in
		let (x3, y3) = (x1 +. 1.0, y1 +. 1.0) in
		let (s1, s2, s3, s4, s5) = 
		  if dir then
			  (x1 /. y1, x1 /. y3, x3 /. y3, x3 /. y1, x2 /. y2)
			else
			  (y1 /. x1, y1 /. x3, y3 /. x3, y3 /. x1, y2 /. x2)
		in
		let (lft, rht) = 
		  let rec sort (mn, mx) lst = match lst with
			  | [] -> (mn, mx)
				| hd::tl -> sort (min hd mn, max hd mx) tl
			in
			  sort (s1, s1) [s2; s3; s4]
		in
		  (* If the middle of the square is within the draw distance *)
		  if (sqrt (x2 ** 2.0 +. y2 ** 2.0)) <= (float_of_int draw_dist) then begin
			  (* We check to see if any angle is visible, and make it visible *)
				if List.exists (fun x -> not (Itree.mem x itree)) [s1; s2; s3; s4; s5] then
				  Tile.set (visible lor mapped) tile;
				(* If the tile is opaque, add it to the block list *)
			  if Tile.is opaque tile then Itree.add (lft, rht) itree
				else itree
			end else itree
  in
	let fold_it itree i dir c =
	  let f itree d = if dir then do_it itree dir d c else do_it itree dir c d in
		let (p, m) = if dir then (pos.x, Map.width map) else (pos.y, Map.height map) in
		let lst = (number_list (max 0 (p - i)) (min (m - 1) (p + i))) in
	    List.fold_left f itree lst
  in 
	let fov_iter (ntree, etree, stree, wtree) i =
	  (fold_it ntree i true (max 0 (pos.y - i)), 
		 fold_it etree i false (min (pos.x + i) (Map.width map - 1)), 
		 fold_it stree i true (min (pos.y + i) (Map.height map - 1)), 
		 fold_it wtree i false (max 0 (pos.x - i)))
	in
	  List.fold_left fov_iter 
		               (Itree.empty, Itree.empty, Itree.empty, Itree.empty) 
		               (number_list 0 draw_dist)
