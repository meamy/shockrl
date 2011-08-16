open Curses;;

module HT = Hashtbl.Make(struct
                           type t = int
                           let equal = (=)
                           let hash = Hashtbl.hash
                         end)

type command =
  | None
  | Left
  | Right
  | Up
  | Down
  | Accept
  | Cancel
  | Quit
  | Save
  | Attack
  | Inventory
  | Use

let key_map = HT.create 32

let lookup key =
  try HT.find key_map key
  with Not_found -> None

let load_defaults () = 
  let defaults = [
    (Key.left, Left);
    (Key.right, Right);
    (Key.up, Up);
    (Key.down, Down);
    (10, Accept);
    (27, Cancel);
    (int_of_char 'q', Quit);
    (int_of_char 's', Save);
    (int_of_char 'f', Attack);
    (int_of_char 'i', Inventory);
    (int_of_char 'u', Use);

    (* Vikeys *)
    (int_of_char 'k', Up);
    (int_of_char 'j', Down);
    (int_of_char 'h', Left);
    (int_of_char 'l', Right)]
  in
    List.iter (fun (key, cmd) -> HT.add key_map key cmd) defaults
