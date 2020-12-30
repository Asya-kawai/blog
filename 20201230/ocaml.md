# Tips to create command line tools in OCaml

I recently created command line tools in OCaml,
then I found better ways to write functions.

This article provies these tips to help those who write command line tools in OCaml.

## How to handle command line arguments

```
(* main function *)
let () =
  let option_len = 1 in
  if (Array.length Sys.argv - 1) != option_len then
    begin
      usage ();
      exit 1
    end
  else
    (* do main actions *)
```

* The program entry point such as `func main` is `let ()` in OCaml.
* `option_len` indicates the number of options.
* When checking the number of options, compare it with `(Array.length Sys.argv - 1)`.
* `Sys.argv - 1` means that excepts command_name. The command name is `Sys.argv`. It can be obtained from (0).
* If the amount of options is incorrect, you need to indicate how to usa it and exit program with an exit status code(non zero).
* if you indicate usage, you must enclose the list of functions in `begin` and `end` or `(` and `)` because it is a side effect for this program.
* In `else`, do main actions.

## How to show usage

```
let usage () =
  let prog = Sys.argv.(0) in
  let s = String.concat "\n" [
              "Usage: ";
              "  " ^ prog ^ " <option_1>" ^ " <option_2>" ^ " [optional_arguments]" ^ "[optional_argment <of_argument>]";
              "";
              "Example: ";
              "  " ^ prog ^ " option_1 option_2 -v -f sample.txt";
            ]
  in
  Printf.eprintf "%s\n" s
```

* Usage function takes a unit type(`()`) argument and returns a unit type(`()`).
* `Sys.argv.(0)` is its own command name.
* `String.concat` is useful if you want to show so long usage.
* `String.concat` takes a seprator(`"\n"` in the above example) and a string list, returns the elements of string list concatenated by the delimiter `"\n"`.
* Finally, return the strings into stderr.

## How to run commands and handle its results

```
exception Command_error of string

let get_stdout command =
  let (in_chan, out_chan, err_chan) = Unix.open_process_full command [||] in
  let rec read_chan in_chan result =
    try
      let r = input_line in_chan in
      read_chan in_chan (r :: result)
    with
    | End_of_file -> List.rev result
  in
  match (read_chan in_chan [], read_chan err_chan []) with
  | (out_strs, []) ->
     let _ = Unix.close_process_full (in_chan, out_chan, err_chan) in
     out_strs
  | ([], err_strs) ->
     let _ = Unix.close_process_full (in_chan, out_chan, err_chan) in
     let err_msg = String.concat "" err_strs in
     raise (Command_error (Printf.sprintf "%s: %s" command err_msg))
  | (_, _) ->
     let _ = Unix.close_process_full (in_chan, out_chan, err_chan) in
     ""
```

* Define an exception(`Command_error` in the above example) if necessary.
* `Unix.open_process_full` is useful to handle outputs when run commands because it returns stdout, stdin and stderr channels.
* `in_chan` means the input channle for inputing the result to `in_chan`.
* Use a recursive function(`read_chan` in the above example) or a `while` statement when processing all stdout strings.
* A `End_of_file` exception is returned at the end of the stdout string, so you must handle it by enclosing it in` try` and `with` and return the result when you catch the` End_of_file`.
* Otherwise, certain exceptions may occur.
* If you want to hanlde stdout and stderr from command, get it from `in_chan` and `err_chan` and check whether the reuslt is empty or not.
* When stderr is empty, the command ran successfully and can handle the result(`out_strs` in the above example).
* But otherwise(stderr is NOT empty) you need to handle stderr and raise an exception(`Command_error` in the above exapmle).
* NOTE: These chanels(`in_chan`, `out_chan` and `err_chan`) must be closed after reading from these channel.
* If none of them are true, it returns an empty string(`""`).
