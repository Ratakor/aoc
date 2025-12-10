module Impl = struct
  let is_invalid regex n = Str.string_match regex (string_of_int n) 0

  let solve input p =
    input
    |> Utils.Input.tokenize_on_char ','
    |> List.fold_left
         (fun acc str ->
           str
           |> String.split_on_char '-'
           |> List.map int_of_string
           |> (function
           | [ start; stop ] -> (start, stop)
           | _ -> failwith "Invalid input")
           |> Pair.fold List.( -- )
           |> List.fold_left (fun acc n -> if p n then acc + n else acc) acc)
         0

  let part1 input = solve input (is_invalid @@ Str.regexp {|^\([0-9]+\)\1$|})
  let part2 input = solve input (is_invalid @@ Str.regexp {|^\([0-9]+\)\1+$|})
end

module Day02 : Day.Solution = Impl
include Impl

let () = Days.register "2" (module Day02)
