module Impl = struct
  let parse input =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map (fun line ->
        line
        |> String.split_on_char ','
        |> List.map int_of_string
        |> function
        | [ x; y ] -> (x, y)
        | _ -> failwith "Invalid point")

  let area (x1, y1) (x2, y2) = (abs (x1 - x2) + 1) * (abs (y1 - y2) + 1)

  let part1 input =
    let points = parse input in
    points
    |> List.fold_left
         (fun (a, i) p ->
           points
           |> List.drop i
           |> List.fold_left (fun a q -> max a (area p q)) a
           |> fun a -> (a, i + 1))
         (0, 1)
    |> fst

  let part2 input =
    let points = parse input in
    ignore points;
    0
end

module Day09 : Day.Solution = Impl
include Impl

let () = Days.register "9" (module Day09)
