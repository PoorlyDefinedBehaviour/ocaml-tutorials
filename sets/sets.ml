(* Create a set of strings *)
module StringSet = Set.Make (String)

let print_set set = StringSet.iter print_endline set

(* Start with the empty set *)
let () =
  print_endline "--- empty set";
  print_set StringSet.empty

(* Start with one element *)
let () =
  print_endline "--- singleton set";
  print_set (StringSet.singleton "hello")

let () =
  let s =
    List.fold_right StringSet.add
      [ "hello"; "world"; "community"; "manager"; "stuff"; "blue"; "green" ]
      StringSet.empty
  in
  print_endline "--- set with several elements";
  print_set s;
  print_endline
    (Printf.sprintf "is \"world\" in the set? %b" (StringSet.mem "world" s))
