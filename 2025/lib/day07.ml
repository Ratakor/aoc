module Impl = struct
  let find_start m =
    ( m.(0)
      |> Array.find_index (fun c -> Char.(c = 'S'))
      |> Option.get_exn_or "Invalid input",
      1 )

  let part1 input =
    let m = Matrix.of_string input in
    let start = find_start m in
    let h = Matrix.height m and w = Matrix.width m in
    (* could probably be merged with part2 but this got nice visualization *)
    let rec aux (x, y) =
      if x < 0 || x >= w || y >= h then 0
      else
        match m.(y).(x) with
        | '.' ->
            m.(y).(x) <- '|';
            aux (x, y + 1)
        | '^' -> 1 + aux (x - 1, y) + aux (x + 1, y)
        | '|' -> 0
        | _ -> failwith "Invalid char"
    in
    aux start

  let part2 input =
    let m = Matrix.of_string input in
    let start = find_start m in
    let h = Matrix.height m and w = Matrix.width m in
    let aux self (x, y) =
      if x < 0 || x >= w then 0
      else if y >= h then 1
      else
        match m.(y).(x) with
        | '.' -> self (x, y + 1)
        | '^' -> self (x - 1, y) + self (x + 1, y)
        | _ -> failwith "Invalid char"
    in
    Memo.memo_rec aux start
end

module Day07 : Day.Solution = Impl
include Impl

let () = Days.register "7" (module Day07)
