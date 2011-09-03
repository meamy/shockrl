open Util;;
open Curses;;

module Buffer = Log.Buffer

exception Read_error

(* Message Log *)
let message_log = Buffer.make !Config.log_size ""

(* Print the last messages to the console *)
let print () =
  let win = !Display.dialogue_win in
  try
    let lst = (Buffer.length message_log - 1) in
      for i = 0 to (Config.dialogue_height - 1) do
        wrap (mvwaddstr win i 0 
				      (Buffer.get (lst - i) message_log))
		  done;
		  wrap (wrefresh win)
	with Curses_error -> ()

(* Write to the console *)
let write str = 
  Buffer.add str message_log;
	print ()

(* Read from the console *)
let read str =
  let win = !Display.dialogue_win in
  let rec acc len lst = match getch () with
	  | 10 -> List.fold_left (fun str ch -> (ch ^ str)) "" lst
		| x -> 
      if x = Key.backspace then begin match lst with
        | [] -> acc len lst
        | hd::tl ->
			    ignore (waddch win 8);
				  ignore (waddch win (int_of_char ' '));
				  ignore (wechochar win 8);
				  acc (len - 1) tl
			  end
      else if len < (Config.dialogue_width - 1) then
			  try
          ignore (wechochar win x);
				  acc (len + 1) ((Char.escaped (char_of_int x))::lst)
			  with Invalid_argument _ -> acc len lst
			else 
			  acc len lst
	in
	  ignore (wmove win 0 0);
		ignore (wclrtobot win);
	  ignore (waddstr win str);
		ignore (wmove win 1 0);
		ignore (wrefresh win);
	  try
	    acc 0 []
		with _ -> raise Read_error
