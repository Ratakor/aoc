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
  let min_max a b = if a < b then (a, b) else (b, a)

  let rec combinations = function
    | [] -> []
    | a :: tl -> List.map (fun b -> (a, b)) tl @ combinations tl

  let pairwise l =
    let hd = List.hd l in
    let rec aux = function
      | [] -> []
      | [ lt ] -> [ (lt, hd) ]
      | a :: b :: tl -> (a, b) :: aux (b :: tl)
    in
    aux l

  let part1 input =
    input
    |> parse
    |> combinations
    |> List.fold_left (fun a (p, q) -> max a (area p q)) 0

  let part2 input =
    let points = parse input in
    let connections =
      points
      |> pairwise
      |> List.map (fun ((x1, y1), (x2, y2)) ->
          let xmin, xmax = min_max x1 x2 and ymin, ymax = min_max y1 y2 in
          ((xmin, ymin), (xmax, ymax)))
    in
    points
    |> combinations
    |> List.filter (fun ((x1, y1), (x2, y2)) ->
        let xmin, xmax = min_max x1 x2 and ymin, ymax = min_max y1 y2 in
        connections
        |> List.for_all (fun ((cxmin, cymin), (cxmax, cymax)) ->
            not (xmin < cxmax && xmax > cxmin && ymin < cymax && ymax > cymin)))
    |> List.fold_left (fun a (p, q) -> max a (area p q)) 0
end

module Day09 : Day.Solution = Impl
include Impl

let () = Days.register "9" (module Day09)
