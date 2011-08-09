module Command = struct
  let none = 0
  let left = 1
  let right = 2
  let up = 3
  let down = 4
  let accept = 5
  let quit = 6
  let save = 7
  let attack = 8
  let inventory = 9
  let use = 10

  let lookup_cmd key =
