(** From https://www.baturin.org/code/lwt-counter-server *)

open Lwt
open Lwt.Syntax

let counter = ref 0
let listen_address = Unix.inet_addr_loopback
let port = 9000
let backlog = 10

let handle_message message = 
  match message with 
  | "read" -> string_of_int !counter
  | "inc" -> 
      counter := !counter +1;
      "Counter has been incremented"
  | _ -> "Unknown command"

let rec handle_connection incoming outgoing () = 
  Lwt_io.read_line_opt incoming >>=  
  (fun msg -> 
      match msg with 
      | Some msg ->
          let reply = handle_message msg in 
          Lwt_io.write_line outgoing reply >>= handle_connection incoming outgoing
      | None -> Logs_lwt.info (fun m -> m "Connection closed") >>= return)

let accept_connection conn = 
  let fd, _ = conn in 
  let in_chan = Lwt_io.of_fd Lwt_io.Input fd in 
  let out_chan = Lwt_io.of_fd Lwt_io.Output fd in 
  Lwt.on_failure (handle_connection in_chan out_chan ()) (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e)));
  Logs_lwt.info (fun m -> m "New connection") >>= return 

let create_server sock = 
  let rec serve () = 
      Lwt_unix.accept sock >>= accept_connection >>= serve
  in serve

let create_socket () = 
  let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in 
  let* () = Lwt_unix.bind sock @@ Lwt_unix.ADDR_INET(listen_address, port) in 
  Lwt_unix.listen sock backlog;
  Lwt.return sock

(* 
Run in the terminal: telnet 9000
Press ctrl + ] and type close to terminate the session.
*)
let () =
  Lwt_main.run @@ (
    let* sock = create_socket() in   
    let serve = create_server sock in 
    serve()
  )
  