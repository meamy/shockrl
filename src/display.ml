open Err;;
open Curses;;
open Level;;

let dialogue_height = 2
let dialogue_width  = 80
let view_height     = 20
let view_width      = 80
let status_height   = 2
let status_width    = 80

let dialogue_win = ref null_window
let view_win     = ref null_window
let status_win   = ref null_window

let messages = Array.make 2 ""

let bootstrap_display () =
  try
    (* init ncurses *)
	  ignore (initscr ()); (* Start ncurses mode *)
    wrap (raw ());    (* Line buffering disabled *)
	  wrap (keypad (stdscr ()) true); (* Get arrow keys *)
	  wrap (noecho ());  (* Don't echo chars *)
	  Colour.init_colours (); (*Initialize colours *)
	  ignore (curs_set 0); (* Hide cursor *)
    flushinp ()
	with
	  Curses_error -> failwith "Error initializing display"

let bootstrap_hud () =
  (* Initialize windows *)
	dialogue_win := newwin dialogue_height dialogue_width 0 0;
	view_win     := newwin view_height view_width dialogue_height 0;
	status_win   := newwin status_height status_width (dialogue_height + view_height) 0;

	(* Check windows *)
	if List.exists (fun win -> !win = null_window) [dialogue_win; view_win; status_win] then
	  failwith "Error initializing HUD";
	
	(* Change attributes *)
  wattrset !dialogue_win (A.color_pair Colour.white);
	wattrset !status_win (A.color_pair Colour.white)

let close_hud () =
  let close_win win =
    wclear win;
	  wrap (wnoutrefresh win);
	  delwin win
	in
	  List.iter (fun x -> wrap (close_win !x)) 
		          [dialogue_win; view_win; status_win];
		wrap (doupdate ())

let print_messages () =
  let f i str = wrap (mvwaddstr !dialogue_win i 0 str) in
    try 
      Array.iteri f messages;
      wrap (wrefresh !dialogue_win)
    with Curses_error -> ()


let add_message str =
  Log.log messages.(1);
  messages.(1) <- messages.(0);
  messages.(0) <- str;
  print_messages ()

let print_map map =
  if !view_win = null_window then
	  failwith "HUD not initialized";
  try Map.print map !view_win;
	    wrap (doupdate ())
	with Curses_error -> failwith "Error displaying map"
