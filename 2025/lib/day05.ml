module Day05 : Day.Solution = struct
  type inventory =
    | Range of (int * int)
    | Ingredient of int

  let parsers =
    [
      Utils.Input.parse "%d-%d" (fun start stop -> Range (start, stop));
      Utils.Input.parse "%d" (fun ingredient -> Ingredient ingredient);
    ]

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
    let parsed =
      input
      |> Utils.Input.tokenize_on_char '\n'
      |> List.map (Utils.Input.try_parse parsers)
    in
    ( parsed
      |> List.filter_map (function
        | Range x -> Some x
        | _ -> None)
      |> merge_ranges,
      parsed
      |> List.filter_map (function
        | Ingredient x -> Some x
        | _ -> None) )

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

let () = Days.register "5" (module Day05)
