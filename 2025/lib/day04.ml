module Impl = struct
  let directions =
    [ (-1, -1); (0, -1); (1, -1); (-1, 0); (1, 0); (-1, 1); (0, 1); (1, 1) ]

  let to_grid input =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map (fun s -> s |> String.to_seq |> Array.of_seq)
    |> Array.of_list

  let neighbors grid x y =
    let h = Array.length grid and w = Array.length grid.(0) in
    List.filter_map
      (fun (dx, dy) ->
        let nx = x + dx and ny = y + dy in
        (* these checks could be removed by padding the grid *)
        if nx >= 0 && nx < w && ny >= 0 && ny < h then Some (nx, ny) else None)
      directions

  let is_accessible grid x y =
    List.fold_left
      (fun acc (nx, ny) -> acc + Bool.to_int (grid.(ny).(nx) = '@'))
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

  let remove_rolls grid =
    let rec loop idxs =
      match idxs with
      | [] -> grid
      | _ ->
          List.iter (fun (x, y) -> grid.(y).(x) <- 'x') idxs;
          loop @@ get_accessible_idxs grid
    in
    loop @@ get_accessible_idxs grid

  let count_removed_rolls grid =
    Array.fold_left
      (fun acc row ->
        Array.fold_left (fun acc cell -> acc + Bool.to_int (cell = 'x')) acc row)
      0 grid

  let part1 input = input |> to_grid |> get_accessible_idxs |> List.length
  let part2 input = input |> to_grid |> remove_rolls |> count_removed_rolls
end

module Day04 : Day.Solution = Impl
include Impl

let () = Days.register "4" (module Day04)
