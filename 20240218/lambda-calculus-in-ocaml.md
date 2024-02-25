# OCamlでLambda計算

Lambda計算とは次の3つの項で構成される式である。

```
x             : 変数
f x           : 関数適用
Lambda(x).f x : ラムダ抽象
```

別の表現として、汎用的な項t（メタ変数t）で表すと下記のように書くことができる。

```
t ::= 
      x
      t t
      Lambda(x).t
```

xは任意の変数を表すメタ変数である。

`f x`のfは任意の関数を表すメタ変数であり、別表現の`t t`から分かるとおり、fは変数やラムラ抽象で表現される。  
たとえば、`f x`は`f (g x) (h x)`や`Lambda(x).(f x) x`のような構文が該当する。

`Lambda(x).f x`はラムダ項に関数を導入するための構文である。

## 操作的意味論

ラムダ計算の「計算」とは、引数（引数も関数）に対する関数の適用である。

関数の仮引数を実引数で置き換える操作をベータ簡約という。

また、変数名を別の変数名で置き換える操作をアルファ簡約という。

---

ベータ簡約とは、例えば`(Lambda(x).f x) y`という式が与えられたとき、`f y`を得る操作である。

また、アルファ簡約とは、`Lambda(x).f (g x) (h x)`という式が与えられたとき、`Lambda(y).f (g y) (h y)`のようｎ変数名を置き換える操作である。

## OCamlでラムダ計算をモデリング

ラムダ計算に関する項をOCamlで定義すると以下のようになる。

```
type expr =
  | Var of string
  | App of expr * expr
  | Lam of string * expr
```

前述のラムダ計算の項と上記を対応付けると下記のようになる。

```
Lambda Calculus | OCaml
-----------------------
x               | Var "x"
f x             | App (Var "f", Var "x")
Lambda(x).f x   | Lam ("x", App (Var "f", Var "x"))
```

## OCamlでラムダ計算をパース

パーサコンビネータライブラリである[Angstrom](https://github.com/inhabitedtype/angstrom)を利用する。

```
open Angstrom
```

カッコで囲まれた項をパースする関数`parens_p`は、
引数にパース対象である式`p`を受け取り、それがカッコで囲まれていれば`p`の結果を返す。

```
let parens_p p = char '(' *> p <* char ')'
```

`name_p`は式`p`がa~zで表現される文字を受け取り、受け取った文字列を返す。  
（具体的には式`p`においてa-zが続く限り受け取り続け、a-z以外がヒットした場合、それ以前に受け取った文字列を返す）

```
let name_p =
    take_while1 (function 'a' .. 'z' -> true | _ -> false)
```

`var_p`は`name_p`が返す文字列を`Var <文字列>`として返す。

```
let var_p = name_p >>| (fun name -> Var name)
```

`app_p`は 式`expr_p`を受け取り、カッコで囲まれた関数名、スペース、式（ラムダ項であるVar, App, Lamのいずれか）をパースし、`App ...`として返す。

```
let app_p expr_p =
  let ( let* ) = (>>=) in
  let* l = parens_p expr_p in
  let* _ = char ' ' in
  let* r = parens_p expr_p in
  return (App (l, r))
```

ここで`let (let *) = (>>=)`はletオペレータを定義しており、下記構文と同じである（下記の糖衣構文である）。

```
( let* ) (parens_p expr_p) (fun l ->
  ( let* ) (char ' ') (fun _ ->
    ( let* ) (parens_p expr_p) (fun r ->
      return (App (l, r)))))
```

`lam_p`も`app_p`と同様なので説明は割愛する。

```
let lam_p expr_p =
  let ( let* ) = (>>=) in
  let* _ = string "Lambda" in
  let* var = parens_p name_p in
  let* _ = char '.' in
  let* body = parens_p expr_p in
  return (Lam (var, body))
```

`expr_p`は与えられた式から`var_p`,`app_p`,`lam_p`,`parens_p`の場所を計算し、その場所を該当する関数定義でパースする。

```
let expr_p: expr t =
  fix (fun expr_p ->
    var_p <|> app_p expr_p <|> lam_p expr_p <|> parens_p expr_p
  )
```

最後に、`parse_string`にて与えられた文字列`str`の下で`expr_p`を適用し、構文をパースする。

```
let parse str =
  match parse_string ~consume:All expr_p str with
  | Ok expr   -> Printf.printf "Success: %s\n%!" (pretty_sprint expr)
  | Error msg -> failwith msg
```
