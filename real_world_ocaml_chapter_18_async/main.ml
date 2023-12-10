open Core
open Async

let blocking_file_ops_example () : unit =
  Out_channel.write_all "test.txt" ~data:"This is only a test.";
  In_channel.read_all "test.txt" |> print_endline

let async_file_ops_example () : string Deferred.t =
  Reader.file_contents "test.xt"

let uppercase_file_bind_function (filename : string) : unit Deferred.t =
  Deferred.bind (Reader.file_contents filename) ~f:(fun contents ->
      Writer.save filename ~contents:(String.uppercase contents))

(* Same as uppercase_file_bind_operator using >>= instead of calling Deferred.bind *)
let uppercase_file_bind_operator (filename : string) : unit Deferred.t =
  Reader.file_contents filename >>= fun contents ->
  Writer.save filename ~contents:(String.uppercase contents)

let count_lines_return (filename : string) : int Deferred.t =
  Reader.file_contents filename >>= fun contents ->
  (*
    return wraps 'a in a Deferred.t:
    val return : 'a -> 'a Deferred.t
    
    Need the return at the end to wrap the value in a Deferred.t because bind (>>=) 
    expects a function that takes 'a and returns 'b Deferred.t.
  *)
  String.split contents ~on:'\n' |> List.length |> return

let count_lines_map (filename : string) : int Deferred.t =
  Reader.file_contents filename (* >>| is Deferred.map *) >>| fun contents ->
  String.split contents ~on:'\n' |> List.length

let count_lines_let_bind (filename : string) : int Deferred.t =
  let%bind contents = Reader.file_contents filename in
  String.split contents ~on:'\n' |> List.length |> return

let count_lines_let_map (filename : string) : int Deferred.t =
  let%map contents = Reader.file_contents filename in
  String.split contents ~on:'\n' |> List.length

let%test_unit "debug" = blocking_file_ops_example ()
