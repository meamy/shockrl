open Util;;
open Curses;;
open Display;;

let width = 30
let height = 10

let new_game () = Game.new_game ()
let continue () = ()
let instructions () = ()
let credits () = ()
let exit () = 
  clear ();
  endwin ()

let options = [|
  ("New Game", new_game);
  ("Continue", continue);
  ("Instructions", instructions);
  ("Credits", credits);
  ("Exit", exit)|]
let nops = Array.length options

let print_title () =
  attron ((A.color_pair Colour.green) lor A.bold);
	wrap (mvaddstr 3 0 "        88888888  888  888 88888888 doooooo 888  ,dP d88:88o  888\n");
 	wrap (addstr       "        88ooooPp  88888888 888  888 d88     888o8P'  888888P  888\n");
 	wrap (addstr       "               d8 88P  888 888  888 d88     888 Y8L  88P d8   888\n");
 	wrap (addstr       "        8888888P  88P  888 888oo888 d888888 888  `8p 88P  48n 888PPPPP\n");
  attroff ((A.color_pair Colour.green) lor A.bold);
  refresh ()

let main_menu () =
  let menu_win = newwin 10 60 10 8 in
  let offs = 2 in
  let print_options () =
    let print_option i (str, _) =
      ignore (mvwaddstr menu_win (i + offs) 2 str)
    in
      Array.iteri print_option options
  in
  let rec get_choice i = 
    mvwchgat menu_win (i + offs) 1 (width - 3) A.bold 2;
    wrap (wrefresh menu_win);
    match Cmd.lookup (getch ()) with
      | Cmd.Up -> if i > 0 then begin
          mvwchgat menu_win (i + offs) 1 (width - 3) A.normal 4;
          get_choice (i - 1)
        end else get_choice i
      | Cmd.Down -> if i < (nops-1) then begin
          mvwchgat menu_win (i + offs) 1 (width - 3) A.normal 4;
          get_choice (i + 1)
        end else get_choice i
      | Cmd.Accept -> 
          wclear menu_win;
          wrap (delwin menu_win);
          (snd options.(i)) ()
      | _ -> get_choice i
  in
    wrap (print_title());
    wattrset menu_win (A.color_pair Colour.blue);
    wclear menu_win;
    box menu_win 0 0;
    print_options ();
    get_choice 0

let init () =
  (* display *)
  bootstrap_display ();

  (* config *)
  Config.load_config ()

let main =
  init ();
	try main_menu ()
	with Curses_error -> failwith "Error displaying menu"
