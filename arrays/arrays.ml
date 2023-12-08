let () =
  let array = [| 1; 2; 3; 4; 5 |] in
  Array.iter (Printf.printf "%d\n") array;

  print_endline "---";

  let array = Array.make 5 1 in
  Array.iter (Printf.printf "%d\n") array;

  print_endline "---";

  (* i is the index *)
  let array = Array.init 5 (fun i -> i * 2) in
  Array.iter (Printf.printf "%d\n") array;
  (* array.(1) is the element access syntax *)
  Printf.printf "element at position 1 is %d\n" array.(1);
  array.(1) <- 42;
  Printf.printf "element at position 1 is %d after it was modified\n" array.(1);

  Printf.printf "the length is %d\n" (Array.length array);

  print_endline "--- for loop";

  for i = 0 to Array.length array - 1 do
    Printf.printf "element at position %d is %d\n" i array.(i)
  done
