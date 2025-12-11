let of_lines lines = lines |> List.map String.to_array |> Array.of_list

let of_string str =
  str |> String.lines |> List.map String.to_array |> Array.of_list

let height m = Array.length m
let width m = Array.length m.(0)

let print m =
  m
  |> Array.iter (fun row ->
      row |> Array.iter (fun cell -> Printf.printf "%c" cell);
      Printf.printf "\n")
