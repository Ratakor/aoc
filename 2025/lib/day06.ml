module Impl = struct
  let rec to_chunks acc seq =
    match seq () with
    | Seq.Nil -> acc
    | Seq.Cons ((i, '+'), next) -> to_chunks ((( + ), (i, 0)) :: acc) next
    | Seq.Cons ((i, '*'), next) -> to_chunks ((( * ), (i, 0)) :: acc) next
    | Seq.Cons ((_, ' '), next) -> (
        match acc with
        | [] -> failwith "Input doesn't start with an op"
        | (op, (i, len)) :: tl -> to_chunks ((op, (i, len + 1)) :: tl) next)
    | _ -> failwith "Invalid char"

  let parse input =
    let max_len =
      input
      |> List.fold_left (fun len s -> max len (String.length s)) 0
      |> ( + ) 1 (* additional padding *)
    in
    input
    |> List.map (String.pad ~side:`Right ~c:' ' max_len)
    |> List.take_last
    |> Pair.map_snd Fun.(String.to_seqi %> to_chunks [])

  let fold_op op l =
    match l with
    | hd :: tl -> List.fold_left op hd tl
    | [] -> assert false

  let part1 input =
    let numbers, chunks = parse input in
    chunks
    |> List.map (fun (op, (pos, len)) ->
        numbers
        |> List.map (fun row ->
            String.sub row pos len |> String.trim |> int_of_string)
        |> fold_op op)
    |> List.fold_left ( + ) 0

  let part2 input =
    let numbers, chunks = parse input in
    chunks
    |> List.map (fun (op, (pos, len)) ->
        List.init len (fun i -> pos + i)
        |> List.map (fun col ->
            numbers
            |> List.map (fun row -> row.[col])
            |> String.of_list
            |> String.trim
            |> int_of_string)
        |> fold_op op)
    |> List.fold_left ( + ) 0
end

module Day06 : Day.Solution = Impl
include Impl

let () = Days.register "6" (module Day06)
