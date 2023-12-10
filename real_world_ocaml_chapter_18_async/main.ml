open! Core

let example_1 () : unit =
  Out_channel.write_all "test.txt" ~data:"This is only a test.";
  In_channel.read_all "test.txt" |> print_endline

let%test_unit "debug" = example_1 ()
