module Impl = struct
  let rtrim s = Str.replace_first (Str.regexp {| +$|}) "" s
  let rpad c n s = s ^ String.init (n - String.length s) (fun _ -> c)

  (* this mf doesn't know about List.filter (fun c -> c <> ' ') *)
  let rec to_chunks acc seq =
    match seq () with
    | Seq.Nil -> acc
    | Seq.Cons ((i, '+'), next) -> to_chunks (('+', (i, 0)) :: acc) next
    | Seq.Cons ((i, '*'), next) -> to_chunks (('*', (i, 0)) :: acc) next
    | Seq.Cons ((_, ' '), next) -> (
        match acc with
        | [] -> failwith "Input doesn't start with an op"
        | (op, (i, len)) :: tl -> to_chunks ((op, (i, len + 1)) :: tl) next)
    | _ -> failwith "Invalid char"

  let parse input =
    let lines =
      input
      |> String.split_on_char '\n'
      |> List.map rtrim
      |> List.filter (fun x -> String.length x > 0)
    in
    let max_len =
      lines
      |> List.fold_left (fun len s -> max len (String.length s)) 0
      |> ( + ) 1 (* padding *)
    in
    lines |> List.map (fun s -> rpad ' ' max_len s) |> List.rev |> function
    | hd :: tl -> (hd |> String.to_seqi |> to_chunks [], List.rev tl)
    | _ -> failwith "Invalid input"

  let fold_op op l =
    match op with
    | '+' -> List.fold_left ( + ) 0 l
    | '*' -> List.fold_left ( * ) 1 l
    | _ -> failwith "Invalid op"

  let part1 input =
    let chunks, numbers = parse input in
    chunks
    |> List.map (fun (op, (pos, len)) ->
        numbers
        |> List.map (fun row ->
            String.sub row pos len |> String.trim |> int_of_string)
        |> fold_op op)
    |> List.fold_left ( + ) 0

  let part2 input =
    let chunks, numbers = parse input in
    chunks
    |> List.map (fun (op, (pos, len)) ->
        List.init len (fun i -> pos + i)
        |> List.map (fun col ->
            numbers
            |> List.map (fun row -> String.get row col)
            |> List.to_seq
            |> String.of_seq
            |> String.trim
            |> int_of_string)
        |> fold_op op)
    |> List.fold_left ( + ) 0
end

module Day06 : Day.Solution = Impl
include Impl

let () = Days.register "6" (module Day06)
