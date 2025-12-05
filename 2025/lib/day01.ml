module Day01 : Day.Solution = struct
  let dial_start = 50
  let dial_size = 100

  let line_to_delta line =
    let n = String.sub line 1 (String.length line - 1) |> int_of_string in
    match String.get line 0 with
    | 'L' -> -n
    | 'R' -> n
    | _ -> failwith "Unexpected char"

  let ( % ) a b =
    let r = a mod b in
    if r < 0 then r + b else r

  let solve input ctz =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map line_to_delta
    |> List.fold_left
         (fun (acc, dial) delta ->
           let dial' = (dial + delta) % dial_size in
           (acc + ctz dial' dial delta, dial'))
         (0, dial_start)
    |> fst

  let part1 input = solve input (fun dial' _ _ -> Bool.to_int (dial' = 0))

  let part2 input =
    solve input (fun _ dial delta ->
        let sum = dial + delta in
        abs (sum / dial_size) + Bool.to_int (sum <= 0 && dial <> 0))
end

let () = Days.register "1" (module Day01)
