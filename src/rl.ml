open Curses

let width = 30
let height = 10

module Colour = struct
  let red = 1
  let green = 2
  let yellow = 3
  let blue = 4
  let magenta = 5
  let cyan = 6
  let white = 7
  let gray = 8

  let init_colours () =
    if not (has_colors ()) then begin
      endwin ();
      failwith "No colour support, quitting..."
    end else begin
      start_color ();
      init_pair red Color.red Color.black;
      init_pair green Color.green Color.black;
      init_pair yellow Color.yellow Color.black;
      init_pair blue Color.blue Color.black;
      init_pair magenta Color.magenta Color.black;
      init_pair white Color.white Color.black
    end
end

let new_game () = ()
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
	mvaddstr 3 0 "        88888888  888  888 88888888 doooooo 888  ,dP d88:88o  888\n";
 	addstr       "        88ooooPp  88888888 888  888 d88     888o8P'  888888P  888\n";
 	addstr       "               d8 88P  888 888  888 d88     888 Y8L  88P d8   888\n";
 	addstr       "        8888888P  88P  888 888oo888 d888888 888  `8p 88P  48n 888PPPPP\n";
  attroff ((A.color_pair Colour.green) lor A.bold);
  refresh ()

let init () =
  (* init ncurses *)
  initscr (); (* Start ncurses mode *)
  raw ();     (* Line buffering disabled *)
  keypad (stdscr ()) true; (* Get arrow keys *)
  noecho ();  (* Don't echo chars *)
  Colour.init_colours (); (*Initialize colours *)
  curs_set 0; (* Hide cursor *)
  flushinp ();

  (* config *)
  Cmd.load_defaults ()

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
    wrefresh menu_win;
    match Cmd.lookup (wgetch menu_win) with
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
          delwin menu_win;
          (snd options.(i)) ()
      | _ -> get_choice i
  in
    keypad menu_win true; (* Get arrow keys *)
    print_title();
    wattrset menu_win (A.color_pair Colour.blue);
    wclear menu_win;
    box menu_win 0 0;
    print_options ();
    get_choice 0

let main =
  init ();
  main_menu ()
