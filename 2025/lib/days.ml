(* This module is used to register and find days. *)
let registry : (string, (module Day.Day)) Hashtbl.t = Hashtbl.create 12

(* Modules register themselves with this function. *)
let register day day_module = Hashtbl.replace registry day day_module

(* This function is used to find a day by its name. *)
let find day = Hashtbl.find_opt registry day
