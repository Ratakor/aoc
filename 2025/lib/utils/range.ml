let of_string s =
  s
  |> String.split_on_char '-'
  |> List.map int_of_string
  |> function
  | [ start; stop ] -> Some (start, stop)
  | _ -> None

let to_seq (start, stop) = Seq.(start -- stop)
