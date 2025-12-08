let of_string str =
  str
  |> Input.tokenize_on_char '\n'
  |> List.map (fun s -> s |> String.to_seq |> Array.of_seq)
  |> Array.of_list

let height m = Array.length m
let width m = Array.length m.(0)

let print m =
  m
  |> Array.iter (fun row ->
      row |> Array.iter (fun cell -> Printf.printf "%c" cell);
      Printf.printf "\n")
