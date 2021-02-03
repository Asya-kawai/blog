# OCaml で Abstract モジュール型を実現する方法

オブジェクト指向でいうところの、抽象基底クラスを実現する方法。

なお、OCaml では オブジェクトも扱えるが、ここでは ABC モジュールの実現を考えてみる。

この[discuss](https://discuss.ocaml.org/t/how-to-abstract-module-types/7200) を見て、
なるほどとなったのでまとめてみたというのが背景。

抽象基底クラスの理解については、Python の [この章](https://docs.python.org/ja/3.5/library/abc.html)
を参考にした。

# ABCモジュール型の定義

ABCモジュールを以下のように定義する。
ここでは、ABCの頭文字を取って、Aモジュール型とした。

※いやー、OCamlにはモジュール型（`sig..end`）とモジュール（`struct...end`）があって混乱しますね...
というわけで、これらについては[OCamlのモジュール (ストラクチャ) とモジュール型 (シグネチャ)](https://qiita.com/keigoi/items/c2d5e07a7b0bae49b18d)
を参考にしてください。

```
module type A = sig
  type t
  type err
  type 'a do_things = t -> ('a, err) result
end
```

Aモジュール型は、型`t`と型`err`、任意の型で表現される`'a do_things`を持つ。


型`t`はAモジュール型が扱う型の総称と思ってもらえれば良い（と思う）。

型`err`は、その名の通りAモジュール型が定義するエラー型。


型`'a do_things`は、ちょっと複雑。なにせ、型名が`'a do_things`だ。

そもそも、`'a` とは何かというと、多相を表す。多相とは何かというと、`任意の型を取れるよ`ということ。

つまり、`string do_things`でも`int do_things`でも良い。

で、`'a do_things`型は、`t`型をとり、`('a, err) result`（`('a, err)`で表現されるresult型）を返す。


多分、ABCモジュール型は抽象的すぎて具体例がないとイメージが沸かないと思うので、ABCモジュール実装を利用する例を次に見ていく。

# ABCモジュールの定義

例えば、ABCモジュール型を利用した`My_a`モジュールを考えてみる。

```
module My_a : A with type t = int and type err = string = struct
 type t = int
 type err = string
 type 'a do_things = t -> ('a, err) result 
end
```

`My_a`は、Aモジュール型が持つ型`t`を`int`、型`err`を`string`と定義した
ものだ。

# ABCモジュールの利用

さらに、ここでAモジュール型に値を追加した、別のCモジュール型を考えてみる。

```
module type C = sig
  module A: A
  val of_int: int -> A.t
  val make: string A.do_things
end
```

`module A: A` はAモジュール型（コロン`:`より右側）をAという名前で扱いますよ、という宣言。

※ 表現が回りくどいよ！まぁざっくり言うとAモジュール型を使いますよってことでOK。


Cモジュール型は、`of_int` （int型の値を引数にとり、`A.t`型を返す）と`make`（`string A.do_thigns`型を返す。
`string`はAモジュール型の`'a`に相当）を定義したものだ。

さて、Cモジュール型を定義したことで、具体的にAモジュールの型を利用する準備が整った。

以降では、このCモジュール型を利用する具体例を見ていく。

# Cモジュールの利用

いよいよ、上記で定義したモジュールを利用する時が来た。

```
module My_c: C = struct
  module A = My_a
  let of_int x = x
  let make x =
    print_endline (string_of_int x) ;
    Ok "ok"
end
```

`module A = My_a` はCモジュール型内で利用するモジュールAを、`My_a`と見立てて、
（つまり、Aモジュール型で宣言されていた`t`は`int`型、`err`は`string`型で）扱う。

`of_int`は、`x`（これはCモジュール型によると`int`型であることがわかる）を引数にとり、`x`（これはCモジュール型によると`A.t`であることがわかる）を返す。

`make`は`x`（これは`My_a`モジュールによれば`t`型）を取り、`Ok "ok"`（これはCモジュール型によれば`(string, err) result`）を返す。

`make`の実行例は以下のような感じ。

```
My_c.make (My_c.of_int 1)

(* 結果 *)
1
- : (string, My_c.A.err) result = Ok "ok"
```

# 参考
* [discuss](https://discuss.ocaml.org/t/how-to-abstract-module-types/7200) 
* [抽象基底クラス](https://docs.python.org/ja/3.5/library/abc.html)
* [OCamlのモジュール (ストラクチャ) とモジュール型 (シグネチャ)](https://qiita.com/keigoi/items/c2d5e07a7b0bae49b18d)


