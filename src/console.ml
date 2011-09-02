open Util;;
open Curses;;

module Buffer = Log.Buffer

(* Message Log *)
let message_log = Buffer.make !Config.log_size ""

let print () = 
  try
    let lst = (Buffer.length message_log - 1) in
      for i = 0 to (Config.dialogue_height - 1) do
        wrap (mvwaddstr !Display.dialogue_win i 0 
				      (Buffer.get (lst - i) message_log))
		  done;
		  wrap (wrefresh !Display.dialogue_win)
	with Curses_error -> ()

let add_message str = 
  Buffer.add str message_log;
	print ()
