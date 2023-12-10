(** From https://github.com/kuy/echo.ml/blob/master/echo.ml *)

open Lwt.Syntax

let create_socket () =
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_STREAM 0 in
  let* () = bind sock @@ ADDR_INET (Unix.inet_addr_loopback, 8080) in
  listen sock 10;
  Lwt.return sock

let handle_message (in_chan : Lwt_io.input_channel)
    (out_chan : Lwt_io.output_channel) : unit Lwt.t =
  let* message = Lwt_io.read_line_opt in_chan in
  match message with
  | None -> Lwt.return ()
  | Some message ->
      let reply =
        match message with
        | "ping" -> "pong"
        | _ -> "unsupported command; " ^ message
      in
      Lwt_io.write_line out_chan reply

let handle_connection conn =
  let fd, _ = conn in
  let in_chan = Lwt_io.of_fd Lwt_io.Input fd in
  let out_chan = Lwt_io.of_fd Lwt_io.Output fd in
  Lwt.ignore_result (handle_message in_chan out_chan);
  Lwt.return_unit

let create_accept_loop sock =
  let rec serve () =
    let* conn = Lwt_unix.accept sock in
    let* () = handle_connection conn in
    serve ()
  in
  serve

let () =
  Lwt_main.run
    (let* sock = create_socket () in
     let loop = create_accept_loop sock in
     loop ())
