module Impl = struct
  module DisjointSet = struct
    type t = { parent : int array }

    let init n = { parent = Array.init n (fun i -> i) }

    let rec find x ds =
      if ds.parent.(x) <> x then ds.parent.(x) <- find ds.parent.(x) ds;
      ds.parent.(x)

    let union x y ds =
      let x = find x ds and y = find y ds in
      if x <> y then ds.parent.(y) <- x;
      x <> y
  end

  (* this actually returns distance squared *)
  let distance (x1, y1, z1) (x2, y2, z2) =
    let dx = x1 - x2 and dy = y1 - y2 and dz = z1 - z2 in
    (dx * dx) + (dy * dy) + (dz * dz)

  let parse input =
    let points =
      input
      |> Utils.Input.tokenize_on_char '\n'
      |> List.map (fun line ->
          Scanf.sscanf line "%d,%d,%d" (fun x y z -> (x, y, z)))
    in
    let edges =
      points
      |> List.foldi
           (fun acc i p ->
             points
             |> List.drop (i + 1)
             |> List.fold_left
                  (fun (acc, j) q -> ((i, j, distance p q) :: acc, j + 1))
                  (acc, i + 1)
             |> fst)
           []
      |> List.sort (fun (_, _, d1) (_, _, d2) -> compare d1 d2)
      |> List.map (fun (i, j, _) -> (i, j))
    in
    (points, edges)

  let part1 input =
    let points, edges = parse input in
    let n = List.length points in
    let ds = DisjointSet.init n in

    edges
    |> List.take 10 (* 10 for sample, 1000 for input *)
    |> List.iter (fun (i, j) -> ds |> DisjointSet.union i j |> ignore);

    let circuits = Array.make n 0 in
    points
    |> List.iteri (fun i _ ->
        let i = ds |> DisjointSet.find i in
        circuits.(i) <- circuits.(i) + 1);
    Array.sort (fun a b -> -compare a b) circuits;
    circuits |> Array.to_seq |> Seq.take 3 |> Seq.fold_left ( * ) 1

  let part2 input =
    let points, edges = parse input in
    let n = List.length points in
    let ds = DisjointSet.init n in

    edges
    |> List.filter (fun (i, j) -> ds |> DisjointSet.union i j)
    |> List.last_opt
    |> Option.get_exn_or "Invalid input"
    |> (fun (i, j) -> (List.nth points i, List.nth points j))
    |> fun ((x1, _, _), (x2, _, _)) -> x1 * x2
end

module Day08 : Day.Solution = Impl
include Impl

let () = Days.register "8" (module Day08)
