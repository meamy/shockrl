open Heap;;

module Hp = Heap.Make(struct 
  type t = int
	let compare = compare
end)

let hp = Hp.empty
let hp2 = Hp.insert 1 'a' hp
let hp3 = Hp.insert 2 'b' hp2
let hp4 = Hp.insert 4 'd' hp3
let hp5 = Hp.insert 3 'c' hp4

let rec doit hp =
  let (_, x) = Hp.get_min hp in
	  print_char x;
		doit (Hp.remove_min hp)

let hello = doit hp5
