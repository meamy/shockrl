exception Curses_error

let wrap b = match b with
  | true -> ()
  | false -> raise Curses_error
