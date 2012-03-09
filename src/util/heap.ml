(* Pairing heaps *)

module Make(M : Map.OrderedType) = struct
  type key = M.t
	type 'a pairHeap = 
	  | Empty 
		| Heap of key * 'a * ('a pairHeap) list
  type 'a t = 'a pairHeap

  exception Empty_heap

	let empty = Empty
	let is_empty hp = match hp with
	  | Empty -> true
		| _ -> false

  let get_min hp = match hp with
    | Empty -> raise Empty_heap
    | Heap (key, elem, _) -> (key, elem)

  let merge hp1 hp2 = match (hp1, hp2) with
	  | (Empty, hp) | (hp, Empty) -> hp
		| (Heap (key1, elem1, sub1), Heap (key2, elem2, sub2)) ->
		    if (M.compare key1 key2) < 0 then
				  Heap (key1, elem1, hp2::sub1)
				else
				  Heap (key2, elem2, hp1::sub2)

	let insert key elem hp =
	  merge (Heap (key, elem, [])) hp

	let remove_min hp =
	  let rec merge_pairs hplst = match hplst with
		  | [] -> Empty
			| hp::[] -> hp
			| hp1::hp2::tl -> merge (merge hp1 hp2) (merge_pairs tl)
	  in
		  match hp with
			  | Empty -> raise Empty_heap
				| Heap (_, _, sub) -> merge_pairs sub
end
