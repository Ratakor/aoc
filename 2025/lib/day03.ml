module Impl = struct
  let digits_of_string s =
    s
    |> String.to_seq
    |> List.of_seq
    |> List.map (fun c -> int_of_char c - int_of_char '0')

  let count_digits n = (n |> float_of_int |> log10) +. 1. |> int_of_float

  (* i to j included *)
  let sublist i j l = l |> List.drop i |> List.take (j - i + 1)

  let find_jolt digits n =
    let rec aux acc first_idx =
      let digit_count = count_digits acc in
      if digit_count = n then acc
      else
        let last_idx = List.length digits - (n - digit_count) in
        let max_idx, max_digit =
          digits
          |> sublist first_idx last_idx
          |> List.foldi
               (fun max idx digit ->
                 if digit > snd max then (idx, digit) else max)
               (-1, -1)
        in
        aux ((10 * acc) + max_digit) (first_idx + max_idx + 1)
    in
    aux 0 0

  let solve input n =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map digits_of_string
    |> List.fold_left (fun acc digits -> acc + find_jolt digits n) 0

  let part1 input = solve input 2
  let part2 input = solve input 12
end

module Day03 : Day.Solution = Impl
include Impl

let () = Days.register "3" (module Day03)
