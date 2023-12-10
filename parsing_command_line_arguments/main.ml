(*
Prints something that looks like this:
[0] _build/default/main.exe      
[1] test   
*)
let sys_argv_example () : unit =
  (* Could use Array.iter as well *)
  for i = 0 to Array.length Sys.argv - 1 do
    Printf.printf "[%i] %s\n" i Sys.argv.(i)
  done

let usage_msg = "append [-verbose] <file1> [<file2>] ... -o <output>"
let verbose = ref false
let input_files = ref []
let output_file = ref ""

(* Handles inputs that don't start with - *)
let handle_anonomyous_input (filename : string) =
  input_files := filename :: !input_files

let speclist =
  [
    ("-verbose", Arg.Set verbose, "Output debug information");
    ("-o", Arg.Set_string output_file, "Set output file name");
  ]

let () = Arg.parse speclist handle_anonomyous_input usage_msg
