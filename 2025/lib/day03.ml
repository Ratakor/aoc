module Day03 : Day.Day = struct
  let digits_of_string s =
    s
    |> String.to_seq
    |> List.of_seq
    |> List.map (fun c -> int_of_char c - int_of_char '0')

  let find_jolt digits =
    let rec aux max i j =
      if j = List.length digits then
        if i + 2 = List.length digits then max
        else
          let n = (10 * List.nth digits (i + 1)) + List.nth digits (i + 2) in
          if n > max then aux n (i + 1) (i + 3) else aux max (i + 1) (i + 3)
      else
        let n = (10 * List.nth digits i) + List.nth digits j in
        if n > max then aux n i (j + 1) else aux max i (j + 1)
    in
    aux 0 0 1

  let solve filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map digits_of_string
    |> List.map find_jolt
    |> List.fold_left ( + ) 0

  let part1 filename = solve filename |> Printf.printf "Part 1: %d\n"
  let part2 filename = solve filename |> Printf.printf "Part 2: %d\n"
end

let () = Days.register "3" (module Day03)
