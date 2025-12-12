module Impl = struct
  type region = {
    width : int;
    length : int;
    presents : int list;
  }

  let parse input =
    input
    |> List.filter_map (fun line ->
        if not @@ String.contains line 'x' then None
        else
          line
          |> String.split ~by:": "
          |> List.hd_tl
          |> Pair.map
               Fun.(
                 String.split_on_char 'x'
                 %> List.map int_of_string
                 %> function
                 | [ width; length ] -> (width, length)
                 | _ -> failwith "Invalid input")
               Fun.(
                 List.hd %> String.split_on_char ' ' %> List.map int_of_string)
          |> (fun ((width, length), presents) -> { width; length; presents })
          |> Option.some)

  (* This is trash that only work for the my given input *)
  let part1 input =
    parse input
    |> List.fold_left
         (fun acc { width; length; presents } ->
           let sum =
             presents |> List.fold_left (fun acc n -> acc + (n * 9)) 0
           in
           acc + Bool.to_int (width * length >= sum))
         0

  let part2 input =
    ignore input;
    0
end

module Day12 : Day.Solution = Impl
include Impl

let () = Days.register "12" (module Day12)
