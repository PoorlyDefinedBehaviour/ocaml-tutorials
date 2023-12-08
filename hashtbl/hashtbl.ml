let () =
  let table = Hashtbl.create 0 in
  Hashtbl.add table "h" "hello";
  Hashtbl.add table "h" "hi";
  Hashtbl.add table "h" "hug";
  Hashtbl.add table "h" "hard";
  Hashtbl.add table "w" "wimp";
  Hashtbl.add table "w" "world";
  Hashtbl.add table "w" "wine";
  Printf.printf "h=%s\n" (Hashtbl.find table "h");
  Printf.printf "w key exists? %b\n" (Hashtbl.mem table "w");
  ()
