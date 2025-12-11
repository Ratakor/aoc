module Impl = struct
  let is_invalid regex n = Str.string_match regex (string_of_int n) 0

  let solve input p =
    input
    |> String.split_on_char ','
    |> List.map String.trim
    |> List.fold_left
         (fun acc str ->
           str
           |> Range.of_string
           |> Option.get_exn_or ("Invalid range: " ^ str)
           |> Range.to_seq
           |> Seq.fold_left (fun acc n -> if p n then acc + n else acc) acc)
         0

  let part1 input = solve input (is_invalid @@ Str.regexp {|^\([0-9]+\)\1$|})
  let part2 input = solve input (is_invalid @@ Str.regexp {|^\([0-9]+\)\1+$|})
end

module Day02 : Day.Solution = Impl
include Impl

let () = Days.register "2" (module Day02)
