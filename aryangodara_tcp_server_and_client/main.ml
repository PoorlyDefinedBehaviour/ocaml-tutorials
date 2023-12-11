(** From https://medium.com/@aryangodara_19887/tcp-server-and-client-in-ocaml-13ebefd54f60 *)

open Lwt.Syntax
open Lwt.Infix

let counter = ref 0

let handle_message (msg : string) : string =
  match msg with
  | "read" -> string_of_int !counter
  | "inc" ->
      counter := !counter + 1;
      "Counter has been incremented"
  | _ -> "Unknown command"

let rec handle_connection (in_chan : Lwt_io.input_channel)
    (out_chan : Lwt_io.output_channel) : unit Lwt.t =
  let* msg = Lwt_io.read_line_opt in_chan in
  match msg with
  | None -> Logs_lwt.info (fun m -> m "Connection closed")
  | Some msg ->
      let reply = handle_message msg in
      let* () = Lwt_io.write_line out_chan reply in
      handle_connection in_chan out_chan

let accept_connection conn : unit Lwt.t =
  let fd, _ = conn in
  let in_chan = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
  let out_chan = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
  Lwt.on_failure (handle_connection in_chan out_chan) (fun err ->
      Logs.err (fun m -> m "%s" (Printexc.to_string err)));
  let* () = Logs_lwt.info (fun m -> m "New connection") in
  Lwt.return_unit

let create_socket () : Lwt_unix.file_descr Lwt.t =
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_STREAM 0 in
  let* () = bind sock @@ ADDR_INET (Unix.inet_addr_loopback, 8001) in
  listen sock 10;
  Lwt.return sock

let create_accept_loop (sock : Lwt_unix.file_descr) : unit -> unit Lwt.t =
  let rec serve () = Lwt_unix.accept sock >>= accept_connection >>= serve in
  serve

let () =
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  let () = Logs.set_level (Some Logs.Info) in
  Logs.info (fun m -> m "starting server");
  Lwt_main.run
    (let* sock = create_socket () in
     let serve = create_accept_loop sock in
     serve ())
