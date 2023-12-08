### Basic expressions

```ocaml
(* "-" appers instead of a name because it is an anonymous expression *)
# 2 + 2;;
- : int = 4

# 50 * 50;;
- : int = 2500

# 6.28;;
- : float = 6.28

# "This is really disco!";;
- : string "This is really disco!";;

# true;;
- : bool = true
```

### Basic lists

```ocaml
# let u = [1; 2; 3; 4];;
val u : int list = [1; 2; 3; 4]

# ["this"; "is"; "mambo"];;
- : string list = ["this", "is", "mambo"]

(* cons operator, used to append to lists *)
# let u = [1; 2; 3; 4];
(* :: is the cons operator *)
# 9 :: u
- : int list = [9; 1; 2; 3; 4]
```

### If

```ocaml
(* if then else is an expression *)
# 2 * if "hello" = "world" then 3 else 5;;
- : int = 10
```

### Let bindings
```ocaml
(* Binding a value to a name *)
# let x = 50;

(* x is an identifier bound to value 50 *)
val x : int = 50;

# x * x;;
- : int = 2500

(* y is only defined locally *)
# let y = 50 in y * y;
- : int = 2500

# y;; (* Error: Unbounded value y *)

# let a = 1 in
  let b = 2 in
    a + b;;
- : int = 3
```

### Structural equality

```ocaml
(* The equality symbol is used in definitions and equality tests *)
# let dummy = "hi" = "hello";;
val dummy : bool = false
```

### Functions

```ocaml
(* Functions are values are defined using the let keyword, there is no return keyword *)
# let square x = x * x;;
val square : int -> int = <fun>
square 50;;
- : int = 2500

(* Anonymous functions do not have a name, and they are defined with the fun keyword *)
# fun x -> x * x;;
- : int -> int = <fun>

# (fun x -> x * x) 50;;
- : int = 2500

# let cat a b = a ^ " " ^ b;;
val cat : string -> string -> string = <fun>

# cat "hello" "world";;
- : string = "hello world"

(* Partial application *)
# let cat_hi = cat "hi";;
val cat_hi : string -> string

# cat_hi "world";;
- : string = "hi world"
```

### List module

```ocaml
# List.map;;
- : ('a -> 'b) -> 'a list -> 'b list = <fun>

# List.map (fun x -> x * x);;
- : int list -> int list = <fun>

# List.map (fun x -> x * x) [0; 1; 2; 3; 4; 5];;
- : int list = [0; 1; 4; 9; 16; 25]
```

### Unit

```ocaml
# read_line;;
- : unit -> string = <fun>

# read_line ();;
caramba
- : string = "caramba"

# print_endline;;
- : string -> unit = <fun>

# print_endline "hello world";;
hello world
- : unit = ()
```

### Recursion

```ocaml
# let rec range lo hi =
    if lo > hi then
      []
    else
       lo :: range (lo + 1) hi;;

val range : int -> int -> list = <fun>

# range 2 5;;
- : int list = [2; 3; 4; 5]
```

### Type conversion and type-inference

```ocaml
# 2.0 +. 2.0;;
- : float = 4.0

(* There is no implicit type conversion *)
# 1 + 2.5;; (* Error: This expression has type float but an expression was expected of type int *)

# float_of_int 1 +. 2.5;;
- : float = 3.5
```

### Lists

```ocaml
(* The empty list, also called nil *)
# [];;
- : 'a list = [];

# [1; 2; 3];;
- : int list = [1; 2; 3]

# [false; false; true];;
- : bool list = [false; false; true]

# [[1; 2]; [3]; [4; 5; 6]]
- : int list list = [[1; 2]; [3]; [4; 5; 6]]

# 1 :: [2; 3; 4];;
- : int list = [1; 2; 3; 4]

# let rec sum u = 
  match u with 
  | [] -> 0
  | head :: tail -> head + sum tail;;

val sum : int list -> int = <fun>

# sum [1; 4; 3; 2; 5];;
- : int = [15]

# let rec length xs =
    match xs with 
    | [] -> 0
    | _ :: tail -> 1 + length tail;;

val length : 'a list -> int = <fun>

# length [1; 2; 3]
- : int = 3

# let square x = x * x;;
val square : int -> int = <fun>

# let map f xs =
    match xs with
    | [] -> []
    | head :: tail -> f head :: map f tail;;
val map : ('a -> 'b') -> 'a list -> 'b list = <fun>

# map square [1; 2; 3; 4];;
- : int list = [1; 4; 9; 16]
```

### Pattern matching, Cont'd

```ocaml
# #show option;;
type 'a option = None | Some of 'a

# let f opt = match opt with 
    | None -> None
    | Some None -> None
    | Some (Some x) -> Some x;;
val f : 'a option option -> 'a option = <fun>

# let g x =
  if x = "foo" then 1
  else if x = "bar" then 2
  else if x = "baz" then 3
  else if x = "qux" then 4
  else 0;;
val g -> string -> int = <fun>

# let g' x =
  match x with 
  | "foo" -> 1
  | "bar" -> 2
  | "baz" -> 3
  | "qux" -> 4
  | _ -> 0;;
val g' -> string -> int = <fun>
```

### Pairs and tuples

```ocaml
# (1, "one", 'K');;
- : int * string * char = (1, "one", 'K')

# ([], false);;
- : 'a list * bool = ([], false)

# let snd tuple = 
    match tuple with
    | (_, b) -> b
val snd : 'a * 'b -> 'b = <fun>

# snd (42, "apple");;
- : string = "apple"
```

### Variants types

```ocaml
# type primary_colour = Red | Green | Blue;;
type primary_colour = Red | Green | Blue

# [Red; Blue; Green];;
- : primary_colour list = [Red; Blue; Green]

# type http_response =
    Data of string
  | Error_code of int;
type http_response = Data of string | Error_code of int

# type page_range =
    | All
    | Current
    | Range of int * int;;
type page_range = All | Current | Range of int * int

# let colour_to_rgb colour = 
    match colour with
    | Red -> (0xff, 0, 0)
    | Green -> (0, 0xff, 0)
    | blue -> (0, 0, 0xff);;
val colour_to_rgb : primary_colour -> int * int * int = <fun>

# let http_status_code response = 
    match response with
    | Data _ -> 200
    | Error_code code -> code
val http_status_code : http_response -> int = <fun>

# let is_printable page_count current range =
    match range with 
    | All -> true
    | Current -> 0 <= current && current < page_count
    | Range (low, high) -> 0 <= low && low <= high && hi < page_count;;
val is_printable: int -> int -> page_range -> bool = <fun>

# #show list;;
type 'a list = [] | (::) of 'a * 'a list
```

### Records

```ocaml
# type person = {
    first_name : string;
    surname: string;
    age: int
};;
type person = { first_name : string; surname : string; age : int; }

# let gerard = {
    first_name = "Gérard";
    surname = "Huet";
    age = 76
};;
val gerard : person = {first_name = "Gérard"; surname = "Huet"; age = 76}

# gerard.surname;;
- : string = "Huet"

# let is_teenager person = 
    match person with
    | { age = x; _ } -> 13 <= x && x <= 19;;
val is_teenager : person -> bool = <fun>

# is_teenager gerard;;
- : bool = false
```

### Exceptions

- Exceptions are raised using the `raise` function. 
- The std lib provides several predefined exceptions.
- It is possible to define exceptions.

```ocaml
# 10 / 0 ;;
Exception: Division_by_zero.

# let id_42 n = if n <> 42 then raise (Failure "Sorry) else n;;
val id_42 : int -> int = <fun>

# id_42 42;;
- : int = 42

# id 0;;
Exception: Failure "Sorry".

# try id_42 0 with Failure _ -> 0;;
- : int = 0
```

### using the resul Type

```ocaml
# #show result;;
type ('a, 'b) result = -> Ok 'a | Error 'b

# let id_42_res n = if n <> 42 then Error "Sorry" else Ok n;;
val id_42_res : int -> (int, string) result = <fun>

# match id_42_res 0 with
    | Ok n -> n
    | Error _ -> 0;;
- : int = 0
```

### Working with Mutable State

```ocaml
# let r = ref 0;;
val r : int ref = { contents = 0 }

# !r;;
- : int = 0

# r := 42;;
- : unit = ()

# let text = ref "hello ";;
val text : string ref = { contents = "hello " }

# print_string !text; text := "world"; print_endline "text;;
hello world!
- : unit = ()
```

### Modules and the Standard Library

```ocaml
# #show Option;;
Module Option :
  sig
    type 'a t = 'a option = None | Some of 'a
    ...
  end

# Option.map;;
- : ('a -> 'b) -> 'a option -> 'b option = <fun>

# List.map;;
- : ('a -> 'b) -> 'a list -> 'b list = <fun>
```