module Impl = struct
  let parse input =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map (fun line -> Scanf.sscanf line "%d,%d" (fun x y -> (x, y)))

  let part1 input =
    let points = parse input in
    points
    |> List.fold_left
         (fun area (x1, y1) ->
           points
           |> List.fold_left
                (fun area (x2, y2) ->
                  max area ((abs (x1 - x2) + 1) * (abs (y1 - y2) + 1)))
                area)
         0

  let part2 input =
    let points = parse input in
    ignore points;
    0
end

module Day09 : Day.Solution = Impl
include Impl

let () = Days.register "9" (module Day09)
