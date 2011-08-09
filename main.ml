open Curses

let width = 30
let height = 10

module C = struct
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
let exit () = ()

let options = [
  ("New Game", new_game);
  ("Continue", continue);
  ("Instructions", instructions);
  ("Credits", credits);
  ("Exit", exit)]


let print_title () =
  attron ((A.color_pair C.green) lor A.bold);
	mvaddstr 3 0 "        88888888  888  888 88888888 doooooo 888  ,dP d88:88o  888\n";
 	addstr       "        88ooooPp  88888888 888  888 d88     888o8P'  888888P  888\n";
 	addstr       "               d8 88P  888 888  888 d88     888 Y8L  88P d8   888\n";
 	addstr       "        8888888P  88P  888 888oo888 d888888 888  `8p 88P  48n 888PPPPP\n";
  attroff ((A.color_pair C.green) lor A.bold);
  refresh ()

let init () =
  initscr (); (* Start ncurses mode *)
  raw ();     (* Line buffering disabled *)
  keypad (stdscr ()) true; (* Get arrow keys *)
  noecho ();  (* Don't echo chars *)
  C.init_colours (); (*Initialize colours *)
  curs_set 0 (* Hide cursor *)

let main_menu () =
  let menu_win = newwin 10 60 10 8 in
  let print_options () =
    let rec print_option options i = match options with
      | [] -> ()
      | (str, _)::tl -> begin 
          mvwaddstr menu_win i 2 str;
          print_option tl (i + 1)
        end
    in
      print_option options 2
  in
    print_title();
    wattrset menu_win (A.color_pair C.blue);
    wclear menu_win;
    box menu_win 0 0;
    print_options ();
    mvwchgat menu_win 2 2 (width - 3) A.bold 2;
    wrefresh menu_win

let main =
  init ();
  main_menu ()
