open Level;;
open Actor;;
open Object;;
open Curses;;
open Util;;

module PQueue = Heap.Make(struct
  type t = int
  let compare = Pervasives.compare
end)

type t = {
  player      : Actor.player;
  current_map : Map.t;
  turn_queue  : Abstract.actor PQueue.t
}

let create () =
  let map = Map.create ~height:40 ~width:80 () in
  let p   = new player map 0 0 in
  { player = p;
    current_map = map;
    turn_queue = PQueue.insert 5 (p :> Abstract.actor) PQueue.empty }

let update_world game = 
  game.player#update_map ();
  wrap (doupdate ())

let timestep game = match PQueue.is_empty game.turn_queue with
  | true -> None
  | false ->
    let (_, actor) = PQueue.get_min game.turn_queue in
    let res = actor#do_turn () in
    update_world game;
    if res = -1 then None
    else Some { game with 
      turn_queue = PQueue.insert res actor (PQueue.remove_min game.turn_queue) }

let resume game =
  let rec timeloop game = match (timestep game) with
    | None -> ()
    | Some game -> timeloop game
  in
  flushinp ();
  Display.bootstrap_hud ();
  update_world game;
  timeloop game;
  Display.close_hud ()


let new_game () =
  let map = Map.create ~height:40 ~width:80 () in
  let p1 = new player map 0 0 in
  let d1 = new door map 21 10 in
  let t1 = new trigger map 21 10 2 d1#open_door d1#close_door in
  let rec time_evo queue = match PQueue.is_empty queue with
    | true -> ()
    | false ->
      let (_, actor) = PQueue.get_min queue in
      let res = actor#do_turn () in
      p1#update_map ();
      wrap (doupdate ());
      if res = -1 then ()
      else time_evo (PQueue.insert res actor (PQueue.remove_min queue))
  in
  flushinp ();
  Display.bootstrap_hud ();
  Tile.assign (Map.get_tile map 20 10) Wall;
  Tile.place (Map.get_tile map 21 10) (d1 :> Abstract.obj);
  p1#reset_fov ();
  p1#set_fov ();
  p1#update_map ();
  wrap (doupdate ());
  time_evo (PQueue.insert 5 (t1 :> Abstract.actor) (PQueue.insert 5 (p1 :> Abstract.actor) (PQueue.empty)));
  Display.close_hud ()
