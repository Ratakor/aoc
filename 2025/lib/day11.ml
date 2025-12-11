module Impl = struct
  let parse input =
    let lines = String.lines input in
    let ht = Hashtbl.create (List.length lines) in
    lines
    |> List.iter (fun line ->
        line
        |> String.split_on_char ':'
        |> function
        | [ name; outputs ] ->
            Hashtbl.add ht name (String.split_on_char ' ' outputs)
        | _ -> failwith ("Invalid line: " ^ line));
    ht

  let part1 input =
    let ht = parse input in
    let rec aux = function
      | "out" -> 1
      | name ->
          name
          |> Hashtbl.get_or ht ~default:[]
          |> List.map aux
          |> List.fold_left ( + ) 0
    in
    aux "you"

  let part2 input =
    let ht = parse input in
    let aux self = function
      | "out", true, true -> 1
      | name, dac, fft ->
          name
          |> Hashtbl.get_or ht ~default:[]
          |> List.map (function
            | "dac" -> self ("dac", true, fft)
            | "fft" -> self ("fft", dac, true)
            | name -> self (name, dac, fft))
          |> List.fold_left ( + ) 0
    in
    Utils.Memo.memo_rec aux ("svr", false, false)
end

module Day11 : Day.Solution = Impl
include Impl

let () = Days.register "11" (module Day11)
