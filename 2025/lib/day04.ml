module Day04 : Day.Solution = struct
  let directions =
    [ (-1, -1); (0, -1); (1, -1); (-1, 0); (1, 0); (-1, 1); (0, 1); (1, 1) ]

  let to_grid input =
    input
    |> List.map (fun s -> s |> String.to_seq |> Array.of_seq)
    |> Array.of_list

  let neighbors grid x y =
    let h = Array.length grid and w = Array.length grid.(0) in
    List.filter_map
      (fun (dx, dy) ->
        let nx = x + dx and ny = y + dy in
        if nx >= 0 && nx < w && ny >= 0 && ny < h then Some (nx, ny) else None)
      directions

  let is_accessible grid x y =
    List.fold_left
      (fun acc (nx, ny) -> acc + if grid.(ny).(nx) = '@' then 1 else 0)
      0 (neighbors grid x y)
    < 4

  let get_accessible_idxs grid =
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
    let rec loop idxs =
      match idxs with
      | [] ->
          (* previous implem was using a mutable counter *)
          Array.fold_left
            (fun acc row ->
              Array.fold_left
                (fun acc cell -> acc + if cell = 'x' then 1 else 0)
                acc row)
            0 grid
      | _ ->
          List.iter (fun (x, y) -> grid.(y).(x) <- 'x') idxs;
          loop @@ get_accessible_idxs grid
    in
    loop @@ get_accessible_idxs grid

  let part1 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char '\n'
    |> to_grid
    |> get_accessible_idxs
    |> List.length
    |> Printf.printf "Part 1: %d\n"

  let part2 filename =
    filename
    |> Utils.Input.read_file_to_string
    |> Utils.Input.tokenize_on_char '\n'
    |> to_grid
    |> solve_part2
    |> Printf.printf "Part 2: %d\n"
end

let () = Days.register "4" (module Day04)
