(* Circular buffer *)
module Buffer = struct
  type 'a t = {
    msg : 'a array;
    mutable fst : int;
    mutable lst : int;
		mutable len : int }

  let make size x = {
    msg = Array.make size x;
    fst = 0;
    lst = 0;
		len = 0 }
	
	let length buf = buf.len

  let add a buf =
    let len = Array.length buf.msg in
    let i = buf.lst in
      buf.msg.(i) <- a;
      if len = buf.len then
        buf.fst <- (i+1) mod len;
      buf.lst <- (i+1) mod len;
			buf.len <- min (buf.len + 1) len
	
	let get i buf = 
	  let len = Array.length buf.msg in
		let x = (buf.fst + i) mod len in
		  if x < 0 then buf.msg.(x + len) else buf.msg.(x)

  let iter f buf =
    let len = Array.length buf.msg in
    let rec iter_rec x = 
      if x != buf.lst then begin
        f buf.msg.(x);
        iter_rec ((x+1) mod len)
      end
    in
      if (buf.fst != buf.lst) then
        iter_rec buf.fst
	
end


(* Debug utilities *)
let debug_file = "debug.log"
let debug_channel = 
  try open_out debug_file
	with Sys_error _ -> failwith "Log: could not open file for debugging"
let debug str =
	output_string debug_channel str;
	output_char debug_channel '\n'
