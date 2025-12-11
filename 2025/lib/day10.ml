module Impl = struct
  type machine = {
    lights : bool array;
    buttons : int array array;
    joltages : int array;
  }

  let pp m =
    Format.printf "@[%a@] @[%a@] @[%a@]@."
      (Array.pp
         ~pp_start:(fun fmt () -> Format.fprintf fmt "[")
         ~pp_stop:(fun fmt () -> Format.fprintf fmt "]")
         ~pp_sep:(fun _ () -> ())
         Char.pp)
      (m.lights |> Array.map (fun l -> if l then '#' else '.'))
      (Array.pp
         ~pp_sep:(fun fmt () -> Format.fprintf fmt " ")
         (Array.pp
            ~pp_start:(fun fmt () -> Format.fprintf fmt "(")
            ~pp_stop:(fun fmt () -> Format.fprintf fmt ")")
            ~pp_sep:(fun fmt () -> Format.fprintf fmt ",")
            Int.pp))
      m.buttons
      (Array.pp
         ~pp_start:(fun fmt () -> Format.fprintf fmt "{")
         ~pp_stop:(fun fmt () -> Format.fprintf fmt "}")
         ~pp_sep:(fun fmt () -> Format.fprintf fmt ",")
         Int.pp)
      m.joltages

  let rec take_last = function
    | [] -> failwith "take_last"
    | [ x ] -> ([], x)
    | hd :: tl -> take_last tl |> Pair.map_fst (List.cons hd)

  let remove_surround s = String.sub s 1 (String.length s - 2)

  let parse input =
    input
    |> Utils.Input.tokenize_on_char '\n'
    |> List.map (fun line ->
        line
        |> Utils.Input.tokenize_on_char ' '
        |> function
        | [] -> failwith ("Invalid line: " ^ line)
        | lights :: tl ->
            let buttons, joltages = take_last tl in
            {
              lights =
                lights
                |> remove_surround
                |> String.to_array
                |> Array.map (Char.equal '#');
              buttons =
                buttons
                |> List.map
                     Fun.(
                       remove_surround
                       %> Utils.Input.tokenize_on_char ','
                       %> List.map int_of_string
                       %> Array.of_list)
                |> Array.of_list;
              joltages =
                joltages
                |> remove_surround
                |> Utils.Input.tokenize_on_char ','
                |> List.map int_of_string
                |> Array.of_list;
            })

  let bfs ?(size = 10) ~start ~successors ~success () =
    let queue = Queue.create () in
    let visited = Hashtbl.create size in
    Queue.add (start, 0) queue;
    Hashtbl.add visited start ();
    let rec bfs' () =
      if Queue.is_empty queue then None
      else
        let node, dist = Queue.pop queue in
        if success node then Some dist
        else (
          successors node
          |> Array.iter (fun succ ->
              if not (Hashtbl.mem visited succ) then (
                Queue.add (succ, dist + 1) queue;
                Hashtbl.add visited succ ()));
          bfs' ())
    in
    bfs' ()

  let press_buttons buttons a op =
    buttons
    |> Array.map (fun button ->
        a
        |> Array.mapi (fun i e ->
            if Array.exists (( = ) i) button then op e else e))

  let swap_row a b i j =
    if i <> j then (
      let tmp = a.(i) in
      a.(i) <- a.(j);
      a.(j) <- tmp;

      let tmp = b.(i) in
      b.(i) <- b.(j);
      b.(j) <- tmp)

  let swap_col a c i j =
    if i <> j then (
      Seq.(0 --^ Array.length a)
      |> Seq.iter (fun k ->
          let tmp = a.(k).(i) in
          a.(k).(i) <- a.(k).(j);
          a.(k).(j) <- tmp);
      let tmp = c.(i) in
      c.(i) <- c.(j);
      c.(j) <- tmp)

  let rec gcd a b = if b = 0 then a else gcd b (a mod b)

  let reduce_row a b i j =
    if a.(i).(i) <> 0 then (
      let x = a.(i).(i) and y = -a.(j).(i) in
      let d = gcd x y in
      Seq.(0 --^ Array.length a.(i))
      |> Seq.iter (fun k ->
          a.(j).(k) <- ((y * a.(i).(k)) + (x * a.(j).(k))) / d);
      b.(j) <- ((y * b.(i)) + (x * b.(j))) / d)

  let reduce (coeffs, joltages, bounds) =
    let rec aux i =
      if i = Array.length coeffs.(0) then ()
      else
        let l = ref [||] in
        let k = ref i in

        while Array.length !l = 0 && !k < Array.length coeffs.(0) do
          swap_col coeffs bounds i !k;
          l :=
            Array.(i --^ Array.length coeffs)
            |> Array.filter (fun j -> coeffs.(j).(i) <> 0);
          incr k
        done;

        if Array.length !l = 0 then ()
        else (
          swap_row coeffs joltages i !l.(0);

          Seq.(i + 1 --^ Array.length coeffs)
          |> Seq.iter (fun j -> reduce_row coeffs joltages i j);

          aux (i + 1))
    in
    aux 0;

    let l =
      Array.(0 --^ Array.length coeffs)
      |> Array.filter (fun i -> coeffs.(i) |> Array.exists (fun a -> a <> 0))
    in
    let coeffs = l |> Array.map (fun i -> coeffs.(i)) in
    let joltages = l |> Array.map (fun i -> joltages.(i)) in

    Seq.(Array.length coeffs - 1 -- 0)
    |> Seq.iter (fun i ->
        Seq.(0 --^ i) |> Seq.iter (fun j -> reduce_row coeffs joltages i j));

    (coeffs, joltages, bounds)

  let rec combinations n c =
    if n = 0 then [ [] ]
    else
      List.(0 -- c.(Array.length c - n))
      |> List.map (fun i ->
          combinations (n - 1) c |> List.map (fun l -> i :: l))
      |> List.flatten

  let solve (coeffs, joltages, bounds) =
    let k = Array.length coeffs.(0) - Array.length coeffs in
    combinations k bounds
    |> List.map Array.of_list
    |> List.map (fun c ->
        let rec aux acc i =
          if i = Array.length coeffs then acc
          else
            let cc =
              Seq.(0 --^ Array.length c)
              |> Seq.map (fun j ->
                  c.(j) * coeffs.(i).(Array.length coeffs.(0) - k + j))
            in
            let s = joltages.(i) - Seq.fold_left ( + ) 0 cc in
            let a = s / coeffs.(i).(i) in
            if a < 0 || s mod coeffs.(i).(i) <> 0 then max_int
            else aux (acc + a) (i + 1)
        in
        aux (Array.fold_left ( + ) 0 c) 0)
    |> List.fold_left min max_int

  let part1 input =
    parse input
    |> List.map (fun m ->
        bfs ()
          ~start:(Array.make (Array.length m.lights) false)
          ~successors:(fun l -> press_buttons m.buttons l not)
          ~success:(fun l -> Array.equal Bool.equal l m.lights)
        |> Option.get_exn_or "bfs failed")
    |> List.fold_left ( + ) 0

  (* Based on https://git.tronto.net/aoc/file/2025/10/b.py.html *)
  let part2 input =
    parse input
    |> List.map (fun m ->
        let coeffs =
          Array.init_matrix (Array.length m.joltages) (Array.length m.buttons)
            (fun i j -> m.buttons.(j) |> Array.exists (( = ) i) |> Bool.to_int)
        and bounds =
          m.buttons
          |> Array.map
               Fun.(
                 Array.map (fun i -> m.joltages.(i))
                 %> Array.fold_left min max_int)
        in
        (coeffs, m.joltages, bounds))
    |> List.map Fun.(reduce %> solve)
    |> List.fold_left ( + ) 0
end

module Day10 : Day.Solution = Impl
include Impl

let () = Days.register "10" (module Day10)
