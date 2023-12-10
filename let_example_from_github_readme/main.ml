open Lwt.Syntax

let () =
  let request =
    let* addresses = Lwt_unix.getaddrinfo "google.com" "80" [] in
    let google = Lwt_unix.((List.hd addresses).ai_addr) in

    Lwt_io.(
      with_connection google (fun (incoming, outgoing) ->
          let* () = write outgoing "GET / HTTP/1.1\r\n" in
          let* () = write outgoing "Connection: close\r\n\r\n" in
          let* response = read incoming in
          Lwt.return (Some response)))
  in
  let timeout =
    let* () = Lwt_unix.sleep 5.0 in
    Lwt.return None
  in
  match Lwt_main.run (Lwt.pick [ request; timeout ]) with
  | Some response -> print_string response
  | None ->
      prerr_endline "Request timed out";
      exit 1
