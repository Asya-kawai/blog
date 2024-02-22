(**
Lambda Calculus | OCaml
-----------------------
x               | Var "x"
f x             | App (Var "f", Var "x")
Lambda(x).f x    | Lam ("x", App (Var "f", Var "x"))
*)
type expr =
  | Var of string
  | App of expr * expr
  | Lam of string * expr

module Parser = struct
  let rec pretty_sprint = function
    | Var x -> x
    | App (left, right) -> Printf.sprintf "(%s) (%s)" (pretty_sprint left) (pretty_sprint right)
    | Lam (arg, body) -> Printf.sprintf "Lambda(%s).(%s)" arg (pretty_sprint body)

  open Angstrom
  let parens_p p = char '(' *> p <* char ')'
  (* [char c] accepts [c] and returns it. *)
  (* [p *> q] runs [p], discards its result and then runs [q], and returns its
      result. *)
  (* [p <* q] runs [p], then runs [q], discards its result, and returns the
      result of [p]. *)

  let name_p =
    take_while1 (function 'a' .. 'z' -> true | _ -> false)
  (* [take_while1 f] accepts input as long as [f] returns [true] and returns the
      accepted characters as a string.

      This parser requires that [f] return [true] for at least one character of
      input, and will fail otherwise. *)

  let var_p = name_p >>| (fun name -> Var name)
  (* [p >>| f] creates a parser that will run [p], and if it succeeds with
      result [v], will return [f v] *)

  let app_p expr_p =
    let ( let* ) = (>>=) in
    (* [p >>= f] creates a parser that will run [p], pass its result to [f], run
        the parser that [f] produces, and return its result. *)
    let* l = parens_p expr_p in
    let* _ = char ' ' in
    let* r = parens_p expr_p in
    return (App (l, r))
  (* [return v] creates a parser that will always succeed and return [v] *)

  let lam_p expr_p =
    let ( let* ) = (>>=) in
    let* _ = string "Lambda" in
    let* var = parens_p name_p in
    let* _ = char '.' in
    let* body = parens_p expr_p in
    return (Lam (var, body))

  let expr_p: expr t =
    fix (fun expr_p ->
        var_p <|> app_p expr_p <|> lam_p expr_p <|> parens_p expr_p
      )
  (* [fix f] computes the fixpoint of [f] and runs the resultant parser. The
      argument that [f] receives is the result of [fix f], which [f] must use,
      paradoxically, to define [fix f].

      [fix] is useful when constructing parsers for inductively-defined types
      such as sequences, trees, etc. Consider for example the implementation of
      the {!many} combinator defined in this library: *)
  (* The only two constructors that introduce new failure continuations are
   * [<?>] and [<|>]. If the initial input position is less than the length
   * of the committed input, then calling the failure continuation will
   * have the effect of unwinding all choices and collecting marks along
   * the way. *)

  let parse str =
    match parse_string ~consume:All expr_p str with
    | Ok expr   -> Printf.printf "Success: %s\n%!" (pretty_sprint expr)
    | Error msg -> failwith msg
    (* [parse_string ~consume t bs] runs [t] on [bs]. The parser will receive an
        [`Eof] after all of [bs] has been consumed. Passing {!Prefix} in the
        [consume] argument allows the parse to successfully complete without
        reaching eof.  To require the parser to reach eof, pass {!All} in the
        [consume] argument.

        For use-cases requiring that the parser be fed input incrementally, see the
        {!module:Buffered} and {!module:Unbuffered} modules below. *)
end

(* test *)
let () =
  Parser.parse "x" ;
  Parser.parse "(f) (x)" ;
  Parser.parse "Lambda(x).((f) (x))"

