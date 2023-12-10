open Lwt.Syntax
open Lwt.Infix

let sleep_and_join_example_1 () : unit Lwt.t =
  (* The promise will tak3 ~2 seconds to complete *)
  Lwt.join [ Lwt_unix.sleep 1.0; Lwt_unix.sleep 2.0 ]

let timeout (delay : float) (promise : 'a Lwt.t) : 'a option Lwt.t =
  let* () = Lwt_unix.sleep delay in
  match Lwt.state promise with
  | Lwt.Sleep ->
      Lwt.cancel promise;
      Lwt.return None
  | Lwt.Return v -> Lwt.return (Some v)
  | Lwt.Fail ex -> Lwt.fail ex

let timeout (delay : float) (promise : 'a Lwt.t) : 'a option Lwt.t =
  Lwt.pick
    [ (Lwt_unix.sleep delay >|= fun () -> None); (promise >|= fun v -> Some v) ]
