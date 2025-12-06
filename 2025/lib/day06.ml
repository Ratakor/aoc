module Impl = struct
  let parse input =
    let lines =
      input
      |> Utils.Input.tokenize_on_char '\n'
      |> List.rev
      |> List.map (Utils.Input.tokenize_on_char ' ')
    in
    let numbers = lines |> List.tl |> List.map (List.map int_of_string) in
    let operations =
      lines
      |> List.hd
      |> List.map (fun s ->
          match String.get s 0 with
          | '+' -> ( + )
          | '*' -> ( * )
          | _ -> failwith "Unexpected op")
    in
    (numbers, operations)

  let[@tail_mod_cons] rec mapf2 lf l1 l2 =
    match (lf, l1, l2) with
    | [], [], [] -> []
    | f :: lf, a :: l1, b :: l2 ->
        let r = f a b in
        r :: mapf2 lf l1 l2
    | _, _, _ -> invalid_arg "mapf2"

  let part1 input =
    let numbers, operations = parse input in
    numbers
    |> List.tl
    |> List.fold_left (fun acc n -> mapf2 operations acc n) (List.hd numbers)
    |> List.fold_left ( + ) 0

  let part2 input =
    ignore input;
    0
end

module Day06 : Day.Solution = Impl
include Impl

let () = Days.register "6" (module Day06)
