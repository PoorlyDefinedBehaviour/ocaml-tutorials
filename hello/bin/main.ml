let () =
  Dream.(
    run ~port:8001
      (router
         [
           get "/" (fun (_ : request) ->
               html (Hello.string_of_string_list Hello.world));
         ]))
