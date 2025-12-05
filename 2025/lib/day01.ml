module Day01 : Day.Solution = struct
  let line_to_instr line =
    ( String.get line 0,
      String.sub line 1 (String.length line - 1) |> int_of_string )

  let wrap n =
    let result = n mod 100 in
    if result < 0 then result + 100 else result

  let rot pos instr =
    match instr with
    | 'L', d -> (wrap (pos - d), ((100 - pos + d) / 100) - Bool.to_int (pos = 0))
    | 'R', d -> (wrap (pos + d), (pos + d) / 100)
    | _ -> failwith "Unexpected char"

  let unlock_safe start f instructions =
    let rec aux acc pos instr =
      match instr with
      | [] -> acc
      | i :: tail ->
          let new_pos, loops = rot pos i in
          aux (f acc (new_pos = 0) loops) new_pos tail
    in
    aux 0 start instructions

  let solve input f =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map line_to_instr
    |> unlock_safe 50 f

  let part1 input = solve input (fun acc is_zero _ -> acc + Bool.to_int is_zero)
  let part2 input = solve input (fun acc _ loops -> acc + loops)
end

let () = Days.register "1" (module Day01)
