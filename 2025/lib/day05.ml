module Impl = struct
  (* is this metaballing? *)
  let merge_ranges ranges =
    let rec aux acc ranges =
      match ranges with
      | [] -> acc
      | [ last ] -> last :: acc
      | (start, stop) :: (next_start, next_stop) :: tail ->
          if stop >= next_start then
            let merged = (start, max stop next_stop) in
            aux acc (merged :: tail)
          else aux ((start, stop) :: acc) ((next_start, next_stop) :: tail)
    in
    ranges |> List.sort (fun (a, _) (b, _) -> compare a b) |> aux []

  let parse input =
    input
    |> List.split_at String.(( = ) "")
    |> Pair.map
         (List.map Fun.(Range.of_string %> Option.get_exn_or "Invalid range"))
         (List.map int_of_string)
    |> Pair.map_fst merge_ranges

  let is_fresh ingredient ranges =
    List.exists
      (fun (start, stop) -> ingredient >= start && ingredient <= stop)
      ranges

  let part1 input =
    let ranges, ingredients = parse input in
    ingredients
    |> List.fold_left (fun acc id -> acc + Bool.to_int (is_fresh id ranges)) 0

  let part2 input =
    fst @@ parse input
    |> List.fold_left (fun acc (start, stop) -> acc + (stop - start + 1)) 0
end

module Day05 : Day.Solution = Impl
include Impl

let () = Days.register "5" (module Day05)
