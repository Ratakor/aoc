module Impl = struct
  module DisjointSet = struct
    type t = {
      parent : int array;
      (* rank is overkill here *)
      rank : int array;
    }

    let init n = { parent = Array.init n (fun i -> i); rank = Array.make n 0 }

    let rec find x ds =
      if ds.parent.(x) <> x then ds.parent.(x) <- find ds.parent.(x) ds;
      ds.parent.(x)

    let union x y ds =
      let x = find x ds and y = find y ds in
      if x = y then false
      else (
        if ds.rank.(x) < ds.rank.(y) then ds.parent.(x) <- y
        else if ds.rank.(x) > ds.rank.(y) then ds.parent.(y) <- x
        else (
          ds.parent.(y) <- x;
          ds.rank.(x) <- ds.rank.(x) + 1);
        true)
  end

  (* this actually returns distance squared *)
  let distance (x1, y1, z1) (x2, y2, z2) =
    let dx = x1 - x2 and dy = y1 - y2 and dz = z1 - z2 in
    (dx * dx) + (dy * dy) + (dz * dz)

  let rec fold_lefti f accu i = function
    | [] -> accu
    | a :: l -> fold_lefti f (f accu i a) (i + 1) l

  let parse input =
    let points =
      input
      |> Utils.Input.tokenize_on_char '\n'
      |> List.map (fun line ->
          Scanf.sscanf line "%d,%d,%d" (fun x y z -> (x, y, z)))
    in
    let edges =
      points
      |> fold_lefti
           (fun acc i p ->
             points
             |> List.drop (i + 1)
             |> fold_lefti
                  (fun acc j q -> (i, j, distance p q) :: acc)
                  acc (i + 1))
           [] 0
      |> List.sort (fun (_, _, d1) (_, _, d2) -> compare d1 d2)
    in
    (points, edges)

  let part1 input =
    let points, edges = parse input in
    let n = List.length points in
    let ds = DisjointSet.init n in

    edges
    |> List.take 10 (* 10 for sample, 1000 for input *)
    |> List.iter (fun (i, j, _) -> ds |> DisjointSet.union i j |> ignore);

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

    let i, j, _ =
      edges
      |> List.filter (fun (i, j, _) -> ds |> DisjointSet.union i j)
      |> List.take (n - 1)
      |> List.rev
      |> List.hd
    in
    let x1, _, _ = List.nth points i and x2, _, _ = List.nth points j in
    x1 * x2
end

module Day08 : Day.Solution = Impl
include Impl

let () = Days.register "8" (module Day08)
