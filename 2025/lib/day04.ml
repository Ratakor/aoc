module Impl = struct
  let directions =
    [ (-1, -1); (0, -1); (1, -1); (-1, 0); (1, 0); (-1, 1); (0, 1); (1, 1) ]

  let neighbors grid x y =
    let h = Matrix.height grid and w = Matrix.width grid in
    List.filter_map
      (fun (dx, dy) ->
        let nx = x + dx and ny = y + dy in
        (* these checks could be removed by padding the grid *)
        if nx >= 0 && nx < w && ny >= 0 && ny < h then Some (nx, ny) else None)
      directions

  let is_accessible grid x y =
    List.fold_left
      (fun acc (nx, ny) -> acc + Bool.to_int Char.(grid.(ny).(nx) = '@'))
      0 (neighbors grid x y)
    < 4

  let get_accessible_idxs grid =
    Array.foldi
      (fun acc y row ->
        Array.foldi
          (fun acc x cell ->
            if Char.(cell = '@') && is_accessible grid x y then (x, y) :: acc
            else acc)
          acc row)
      [] grid

  let remove_rolls grid =
    let rec loop idxs =
      match idxs with
      | [] -> grid
      | idxs ->
          List.iter (fun (x, y) -> grid.(y).(x) <- 'x') idxs;
          loop @@ get_accessible_idxs grid
    in
    loop @@ get_accessible_idxs grid

  let count_removed_rolls grid =
    Array.fold_left
      (fun acc row ->
        Array.fold_left
          (fun acc cell -> acc + Bool.to_int Char.(cell = 'x'))
          acc row)
      0 grid

  let part1 input =
    input |> Matrix.of_lines |> get_accessible_idxs |> List.length

  let part2 input =
    input |> Matrix.of_lines |> remove_rolls |> count_removed_rolls
end

module Day04 : Day.Solution = Impl
include Impl

let () = Days.register "4" (module Day04)
