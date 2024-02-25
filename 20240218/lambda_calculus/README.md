# Lambda計算をOCamlで行うためのデモ

## 準備

`https://opam.ocaml.org/doc/Install.html` などのインストールガイドに従って、`opam`をインストールする。

opamインストール後、作業ディレクトリに移動し、環境を作業ディレクトリに限定するため下記コマンドを実行する。

```
opam switch create . ocaml-base-compiler.5.0.0 --no-instal
```

## ライブラリのインストール

Lambda計算をパースするために、[Angstrom](https://github.com/inhabitedtype/angstrom)ライブラリをインストールする。

```
opam install angstrom
```

## duneファイルの編集

duneとは、OCamlのプロジェクトビルドツールである。  
これを用いて外部ライブラリを管理したり、独自定義したライブラリを楽に利用するための設定ファイルを利用できる。

Angstromを利用できるように`./bin/dune`を以下のように修正する。  
`(libraries ...)`に注目。

```
(executable
 (public_name lambda_calculus)
 (name main)
 (libraries lambda_calculus angstrom))
```

## コードのビルド

duneを用いてコードをビルドするために下記コマンドを実行する。

```
dune build bin.main.exe
```

## コードを実行するには下記コマンドを実行する。

```
./_build/default/bin/main.exe
```

# 参考

* [Learn Lambda Calculus in 10 minutes with OCaml](https://dev.to/chshersh/learn-lambda-calculus-in-10-minutes-with-ocaml-56ba)
* [Angstrom](https://github.com/inhabitedtype/angstrom)
* [dune](https://github.com/ocaml/dune)
