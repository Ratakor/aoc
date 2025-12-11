module Impl = struct
  let line_to_delta line =
    let n = String.sub line 1 (String.length line - 1) |> int_of_string in
    match line.[0] with
    | 'L' -> -n
    | 'R' -> n
    | _ -> failwith "Unexpected char"

  let ( % ) a b =
    let r = a mod b in
    if r < 0 then r + b else r

  let solve input ctz =
    input
    |> String.lines
    |> List.map line_to_delta
    |> List.fold_left
         (fun (acc, dial) delta ->
           let dial' = (dial + delta) % 100 in
           (acc + ctz dial' dial delta, dial'))
         (0, 50)
    |> fst

  let part1 input = solve input (fun dial' _ _ -> Bool.to_int (dial' = 0))

  let part2 input =
    solve input (fun _ dial delta ->
        let sum = dial + delta in
        abs (sum / 100) + Bool.to_int (sum <= 0 && dial <> 0))
end

module Day01 : Day.Solution = Impl
include Impl

let () = Days.register "1" (module Day01)
