module Day02 : Day.Day = struct
  let is_invalid regex n = Str.string_match regex (string_of_int n) 0

  let sum_match_range match_fn start stop =
    let rec aux acc i =
      if i > stop then acc
      else if match_fn i then aux (acc + i) (i + 1)
      else aux acc (i + 1)
    in
    aux 0 start

  let range_of_string s =
    s |> String.split_on_char '-' |> List.map int_of_string

  let part1 filename =
    let check = is_invalid @@ Str.regexp {|^\([0-9]+\)\1$|} in
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char ','
    |> List.map range_of_string
    |> List.map (fun range ->
        sum_match_range check (List.nth range 0) (List.nth range 1))
    |> List.fold_left ( + ) 0
    |> Printf.printf "Part 1: %d\n"

  let part2 filename =
    let check = is_invalid @@ Str.regexp {|^\([0-9]+\)\1+$|} in
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char ','
    |> List.map range_of_string
    |> List.map (fun range ->
        sum_match_range check (List.nth range 0) (List.nth range 1))
    |> List.fold_left ( + ) 0
    |> Printf.printf "Part 2: %d\n"
end

include Day02

let () = Days.register "2" (module Day02)
