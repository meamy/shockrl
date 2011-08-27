module Buffer = struct
  type 'a t = {
    msg : 'a array;
    mutable fst : int;
    mutable lst : int }

  let make size x = {
    msg = Array.make size x;
    fst = 0;
    lst = 0 }

  let add a buf =
    let len = Array.length buf.msg in
    let i = buf.lst in
      buf.msg.(i) <- a;
      buf.lst <- (i+1) mod len;
      if buf.lst = buf.fst then
        buf.fst <- (buf.lst + 1) mod len

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

let log_size = 100

let debug_file = "debug.log"
let message_log = Buffer.make log_size ""

let debug_channel = 
  try open_out debug_file
	with Sys_error _ -> failwith "Log: could not open file for debugging"

let debug str =
	output_string debug_channel str;
	output_char debug_channel '\n'

let log str = Buffer.add str message_log
