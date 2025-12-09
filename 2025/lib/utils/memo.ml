let memo ?(init_size = 1000) f =
  let ht = Hashtbl.create init_size in
  fun x ->
    match Hashtbl.find_opt ht x with
    | Some y -> y
    | None ->
        let y = f x in
        Hashtbl.add ht x y;
        y

let memo_rec ?(init_size = 1000) f =
  let ht = Hashtbl.create init_size in
  let rec g x =
    match Hashtbl.find_opt ht x with
    | Some y -> y
    | None ->
        let y = f g x in
        Hashtbl.add ht x y;
        y
  in
  g
