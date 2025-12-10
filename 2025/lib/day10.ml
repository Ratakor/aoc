module Impl = struct
  type machine = {
    lights : bool array;
    buttons : int list list;
    joltages : int array;
  }

  let pp m =
    Format.printf "@[%a@] @[%a@] @[%a@] @."
      (Array.pp
         ~pp_start:(fun fmt () -> Format.fprintf fmt "[")
         ~pp_stop:(fun fmt () -> Format.fprintf fmt "]")
         ~pp_sep:(fun _ () -> ())
         Char.pp)
      (m.lights |> Array.map (fun l -> if l then '#' else '.'))
      (List.pp
         ~pp_sep:(fun fmt () -> Format.fprintf fmt " ")
         (List.pp
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
                       %> List.map int_of_string);
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
          |> List.iter (fun succ ->
              if not (Hashtbl.mem visited succ) then (
                Queue.add (succ, dist + 1) queue;
                Hashtbl.add visited succ ()));
          bfs' ())
    in
    bfs' ()

  let press_buttons buttons a op =
    buttons
    |> List.map (fun button ->
        a
        |> Array.mapi (fun i e ->
            if List.exists (( = ) i) button then op e else e))

  let part1 input =
    parse input
    |> List.map (fun m ->
        bfs ()
          ~start:(Array.make (Array.length m.lights) false)
          ~successors:(fun l -> press_buttons m.buttons l not)
          ~success:(fun l -> Array.equal Bool.equal l m.lights)
        |> Option.get_exn_or "bfs failed")
    |> List.fold_left ( + ) 0

  let part2 input =
    parse input
    |> List.map (fun m ->
        (* pp m; *)
        bfs ()
          ~start:(Array.make (Array.length m.joltages) 0)
          ~successors:(fun j -> press_buttons m.buttons j (( + ) 1))
          ~success:(fun j -> Array.equal Int.equal j m.joltages)
        |> Option.get_exn_or "bfs failed")
    |> List.fold_left ( + ) 0
end

module Day10 : Day.Solution = Impl
include Impl

let () = Days.register "10" (module Day10)
