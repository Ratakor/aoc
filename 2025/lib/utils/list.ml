include CCList

let rec take_last = function
  | [] -> failwith "take_last"
  | [ x ] -> ([], x)
  | hd :: tl -> take_last tl |> Pair.map_fst (CCList.cons hd)

(** i to j included *)
let sub i j l = l |> CCList.drop i |> CCList.take (j - i + 1)

let rec split_at p = function
  | [] -> ([], [])
  | hd :: tl when p hd -> ([], tl)
  | hd :: tl -> split_at p tl |> Pair.map_fst (CCList.cons hd)
