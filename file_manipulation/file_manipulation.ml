let file = "example.dat"
let message = "Hello!"

let () = 
(* Write message to file  *)
  let out_chan = open_out file in 

 (* Create or truncate file, return channel *)
 Printf.fprintf out_chan "%s\n" message;

 (* Close and flush to actually write *)
 close_out out_chan;

  let in_chan = open_in file in 
  try 
    (* Read contents until \n is found, return string without \n *)
    let line = input_line in_chan in 

    print_endline line;

    (* Write the result to stdout *)
    flush stdout;

    (* Close the input channel *)
    close_in in_chan;
  with e ->
 (* Close channel, ignore errors *)
  close_in_noerr in_chan;
  raise e