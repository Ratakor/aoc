let run_day day_module filename =
  let module D = (val day_module : Day.Solution) in
  (* filename |> fun x -> Printf.printf "%d\n%d\n" (D.part1 x) (D.part2 x) *)
  filename |> D.part1 |> Printf.printf "Solution 1: %d\n";
  filename |> D.part2 |> Printf.printf "Solution 2: %d\n"

let run day_str filename =
  match Days.find day_str with
  | Some day_module -> run_day day_module filename
  | None -> Printf.printf "Day %s not implemented yet\n" day_str

let () =
  match Sys.argv with
  | [| _; day_str; filename |] -> run day_str filename
  | [| _; day_str |] -> run day_str "-"
  | _ -> Printf.eprintf "Usage: %s <day> [<filename>]\n" Sys.argv.(0)
