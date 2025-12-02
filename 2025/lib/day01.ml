module Day01 : Day.Day = struct
  let line_to_instr line =
    ( String.get line 0,
      String.sub line 1 (String.length line - 1) |> int_of_string )

  let wrap n =
    let result = n mod 100 in
    if result < 0 then result + 100 else result

  let apply_instr pos instr =
    match instr with
    | 'L', n -> pos - n |> wrap
    | 'R', n -> pos + n |> wrap
    | _ -> failwith "Unexpected char"

  let rot start instructions =
    let rec aux acc pos instr =
      match instr with
      | [] -> acc
      | i :: tail ->
          let new_pos = apply_instr pos i in
          if new_pos = 0 then aux (acc + 1) new_pos tail
          else aux acc new_pos tail
    in
    aux 0 start instructions

  (* I believe we can make a wrap2 function but this looks easier *)
  let backward_clicks pos n =
    if pos = 0 then n / 100 else if n < pos then 0 else ((n - pos) / 100) + 1

  let apply_instr2 pos instr =
    match instr with
    | 'L', n -> (pos - n |> wrap, backward_clicks pos n)
    | 'R', n ->
        let p = pos + n in
        (wrap p, p / 100)
    | _ -> failwith "Unexpected char"

  let rot2 start instructions =
    let rec aux acc pos instr =
      match instr with
      | [] -> acc
      | i :: tail ->
          let new_pos, n = apply_instr2 pos i in
          aux (acc + n) new_pos tail
    in
    aux 0 start instructions

  let part1 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.split_on_newline
    |> List.map line_to_instr
    |> rot 50
    |> Printf.printf "Part 1: %d\n" (* Should we return the result instead? *)

  let part2 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.split_on_newline
    |> List.map line_to_instr
    |> rot2 50
    |> Printf.printf "Part 2: %d\n"
end

include Day01

let () = Days.register "1" (module Day01)
