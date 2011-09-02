(* Random integers *)

let init = Random.init(int_of_float (Unix.time ()))

let get  = Random.int
