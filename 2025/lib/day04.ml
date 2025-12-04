module Day04 : Day.Day = struct
  let input_to_grid input =
    input
    |> List.map (fun s -> s |> String.to_seq |> Array.of_seq)
    |> Array.of_list

  let directions =
    [| (-1, -1); (0, -1); (1, -1); (-1, 0); (1, 0); (-1, 1); (0, 1); (1, 1) |]

  let is_accessible grid x y =
    let h = Array.length grid in
    let w = Array.length grid.(0) in
    let count = ref 0 in
    Array.iter
      (fun (dx, dy) ->
        let nx = x + dx and ny = y + dy in
        if nx >= 0 && nx < w && ny >= 0 && ny < h && grid.(ny).(nx) = '@' then
          incr count)
      directions;
    !count < 4

  let get_accessibles grid =
    let idxs = ref [] in
    Array.iteri
      (fun y row ->
        Array.iteri
          (fun x cell ->
            if cell = '@' && is_accessible grid x y then idxs := (x, y) :: !idxs)
          row)
      grid;
    !idxs

  let solve_part2 grid =
    let removed = ref 0 in
    let rec loop idxs =
      match idxs with
      | [] -> !removed
      | _ ->
          List.iter
            (fun (x, y) ->
              grid.(y).(x) <- 'x';
              incr removed)
            idxs;
          loop (get_accessibles grid)
    in
    loop (get_accessibles grid)

  let part1 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char '\n'
    |> input_to_grid
    |> get_accessibles
    |> List.length
    |> Printf.printf "Part 1: %d\n"

  let part2 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char '\n'
    |> input_to_grid
    |> solve_part2
    |> Printf.printf "Part 2: %d\n"
end

let () = Days.register "4" (module Day04)
