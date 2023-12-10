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

let ivar_intro () =
  let ivar : string Ivar.t = Ivar.create () in
  let deferred = Ivar.read ivar in
  (* None *)
  let _ = Deferred.peek deferred in
  Ivar.fill ivar "hello";
  (* Some "hello" *)
  let _ = Deferred.peek deferred in
  ()

module type Delayer_intf = sig
  type t

  val create : Time.Span.t -> t
  val schedule : t -> (unit -> 'a Deferred.t) -> 'a Deferred.t
end

module Delayer : Delayer_intf = struct
  type t = { delay : Time.Span.t; jobs : (unit -> unit) Queue.t }

  let create (delay : Time.Span.t) : t = { delay; jobs = Queue.create () }

  let schedule (delayer : t) (thunk : unit -> 'a Deferred.t) : 'a Deferred.t =
    let ivar = Ivar.create () in
    Queue.enqueue delayer.jobs (fun () ->
        upon (thunk ()) (fun x -> Ivar.fill ivar x));

    upon (after delayer.delay) (fun () ->
        let job = Queue.dequeue_exn delayer.jobs in
        job ());

    Ivar.read ivar
end

let my_bind (deferred : 'a Deferred.t) ~(f : 'a -> 'b Deferred.t) :
    'b Deferred.t =
  let ivar = Ivar.create () in
  upon deferred (fun x -> upon (f x) (fun y -> Ivar.fill ivar y));
  Ivar.read ivar

(* Copy data from the reader to the writer, using the provided buffer as scratch space *)
let rec copy_blocks (buffer : bytes) (reader : Reader.t) (writer : Writer.t) :
    unit Deferred.t =
  match%bind Reader.read reader buffer with
  | `Eof -> return ()
  | `Ok bytes_read ->
      Writer.write writer (Bytes.to_string buffer) ~len:bytes_read;
      let%bind () = Writer.flushed writer in
      copy_blocks buffer reader writer

(** Starts a TCP server, which listens on the specific port, invoking copy_blocks every time a client connects. *)
let run () =
  let host_and_port =
    Tcp.Server.create ~on_handler_error:`Raise
      (Tcp.Where_to_listen.of_port 8765) (fun _addr reader writer ->
        let buffer = Bytes.create (16 * 1024) in
        copy_blocks buffer reader writer)
  in
  ignore (host_and_port : (Socket.Address.Inet.t, int) Tcp.Server.t Deferred.t);
  never_returns (Scheduler.go ())

let%test_unit "debug" = blocking_file_ops_example ()
