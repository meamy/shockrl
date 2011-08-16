open Core;;
open Curses;;

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
      wrap (start_color ());
      wrap (init_pair red Color.red Color.black);
      wrap (init_pair green Color.green Color.black);
      wrap (init_pair yellow Color.yellow Color.black);
      wrap (init_pair blue Color.blue Color.black);
      wrap (init_pair magenta Color.magenta Color.black);
      wrap (init_pair white Color.white Color.black)
    end
end

let bootstrap_display () =
  (* init ncurses *)
  ignore (initscr ()); (* Start ncurses mode *)
  wrap (raw ());     (* Line buffering disabled *)
  wrap (keypad (stdscr ()) true); (* Get arrow keys *)
  wrap (noecho ());  (* Don't echo chars *)
  Colour.init_colours (); (*Initialize colours *)
  wrap (curs_set 0); (* Hide cursor *)
  flushinp ()
