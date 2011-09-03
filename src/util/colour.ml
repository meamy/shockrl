open Util;;
open Curses;; 

(* Colour definitions *)
let red     = 1
let green   = 2
let yellow  = 3
let blue    = 4
let magenta = 5
let cyan    = 6
let white   = 7
let gray    = 8

let init_colours () =
  if not (has_colors ()) then begin
    endwin ();
    failwith "No colour support, quitting..."
  end else try
    wrap (start_color ());
    wrap (init_pair red Color.red Color.black);
    wrap (init_pair green Color.green Color.black);
    wrap (init_pair yellow Color.yellow Color.black);
    wrap (init_pair blue Color.blue Color.black);
    wrap (init_pair magenta Color.magenta Color.black);
    wrap (init_pair white Color.white Color.black);
    wrap (init_pair gray Color.black Color.black);
  with
    Curses_error -> failwith "Error initializing colours"
