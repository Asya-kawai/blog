# GADTとは何であるか

GADTとはGeneralized Algebraic Data Typesの略で、
データコンストラクタの引数に存在量化された型変数を持てるように一般化されたADTである。

```
type any_list = Any: 'a list -> any_list
```

## なぜGADTが必要か

ADTで複数のデータコンストラクタを取りうるデータ型は、以下のように定義できる。

```
type t = 
  | Int of int
  | Char of char
```

tについて値を取得するための多相的なget関数を定義しようとして以下のように書きたくなるが、
これはできない。

```
let get = function
| Int x -> x
| Char x -> x
```

エラーは次のようになり、`Int x`の戻り値がint型である一方で `Char x`のパターンマッチの戻り値がchar型となってしまうため型の不一致が生じている。

```
Error: This expression has type char but an expression was expected of type int
```

これを解決するのがGADTである。

## GADTで表現する

GADTで表現するには以下の構文を用いる。

https://v2.ocaml.org/manual/gadts.html

先程のtをGADTで書き直すと以下のようになる。

```
type _ t =
| Int : int -> int t
| Char : char -> char t
```

以下のように明示的に書いても良い。

```
type 'a t =
| Int : int -> int t
| Char : char -> char t
```

上記はちょうど、IntやCharといったデータコンストラクタを関数とみなして、その関数の型を定義するようなものだ。

GADTな型に対して多相なget関数を定義するには、[Locally abstract types](https://v2.ocaml.org/manual/locallyabstract.html)を用いる必要がある。

```
let get : type a. a t -> a = function
| Int x -> x
| Char x -> x
```

実行例は以下のとおりで、うまく動作する。

```
get (Int 1) ;;
- : int = 1
get (Char 'a') ;;
- : char = 'a'
```
