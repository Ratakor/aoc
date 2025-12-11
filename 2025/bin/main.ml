let run_day day_module filename =
  let module D = (val day_module : Day.Solution) in
  let input = IO.(with_in filename read_all) in
  Printf.printf "Part 1: %d\nPart 2: %d\n" (D.part1 input) (D.part2 input)

let run day_str filename =
  match Days.find day_str with
  | Some day_module -> run_day day_module filename
  | None -> Printf.printf "Day %s not implemented yet\n" day_str

let () =
  match Sys.argv with
  | [| _; day_str; filename |] -> run day_str filename
  | [| _; day_str |] -> run day_str "/dev/stdin"
  | _ -> Printf.eprintf "Usage: %s <day> [<filename>]\n" Sys.argv.(0)
