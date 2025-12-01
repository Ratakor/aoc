let memo ?(init_size = 1000) ?(key = fun x -> x) f =
  let ht = Hashtbl.create init_size in
  fun x ->
    match Hashtbl.find_opt ht (key x) with
    | Some v -> v
    | None ->
        let v = f x in
        Hashtbl.add ht (key x) v;
        v
