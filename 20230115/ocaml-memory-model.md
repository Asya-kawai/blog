# OCamlのメモリモデルについて

## 序文

これまで[Russ Coxが書いたメモリモデルに関する記事](https://research.swtch.com/mm)について、
Twitterでまとめてきた。

* [Updating the Go Memory Modelの要約](https://twitter.com/asya_aoi1049/status/1610723327412404224?s=20&t=oTRuOvqqnDAtS9nMVWQQfw)

Goのメモリモデルは上記記事にあるように「データ競合のあるプログラムは、実装が競合を報告してプログラムを終了する可能性があり」その意味で無効なプログラムとして処理され、それ以外の場合（例えば部分的にデータ競合のあるプログラム等）はその場合の挙動を予め定義している。

さて、OCaml 5.0.0 は2022/12/16にリリースされたが、この時初めてマルチプロセッサに対応した。
つまり並列処理に対応した（以前は並行処理しかできなかった）。

そこで改めてOCamlのメモリモデルについてしっかりと理解してみる。

## OCamlのメモリモデル概要

モダンなプロセッサとコンパイラは積極的にプログラムを最適化するが、並列処理を含むプログラムに対してその挙動を変えてしまう場合がある。

OCamlでは、`relaxed memory model`（緩いメモリモデル）を採用する。緩いメモリモデルは、緩いプログラムの挙動を正確に捉えるメモリモデルだ。
このようなモデルに基づいて直接プログラミングすることは困難であるが、OCamlのメモリモデルは逐次推論の単純さを保持する仕組みを提供することで、このメモリモデルを実現している。

まず、イミュータブルな値（不変な値）は複数のプロセッサ間で自由に共有でき、並列してアクセス可能だ。
一方ミュータブルなデータ（例えば、参照セル、配列、ミュータブルなレコードフィールド等）について、データ競合を避けなければならない。

データ競合とは、2つのプロセッサ（ドメインと書かれている）が同期処理なしで同時に同じメモリ上のデータにアクセスし且つ少なくとも1つは書き込み処理があるようなアクセスを指す。
なお、OCamlは（一般的なプログラミング言語でも同様であるが）アトミック変数やmutex機構を持っている。

重要なのは、データ競合のない（data race free(DRF)）プログラムに対してOCamlは逐次一貫性（sequentially consistent(SC)）を保証することだ。
DRF-SCとは、異なるプロセッサで動作する場合であっても（単一プロセッサにインタリーブされたかのように）データ競合のないプログラムが常に連続して一貫した方法で実行されることを保証するものだ。
このように「データ競合のないプログラムが常に連続して一貫した方法で実行される」ことをDRF-SC保証と言う。

さらにOCamlでは、DRF-SC保証はモジュール化されており、プログラムの一部にデータ競合がない場合、OCamlのメモリモデルは、プログラムの他の部分にデータ競合があったとしてもそれらの部分（データ競合のない部分）に逐次一貫性があることを保証する。

一方データ競合のあるプログラムに対しても強い保証を提供しており、一貫性のない挙動になってしまうがプログラム全体がクラッシュすることはない。

Reference: [4 Memory Model: The easy bits](https://v2.ocaml.org/releases/5.0/manual/parallelism.html#s:par_mm_easy)

Reference: * [Chapter 10 Memory Model: The hard bits](https://v2.ocaml.org/releases/5.0/manual/memorymodel.html#c%3Amemorymodel)

# まとめ

* OCamlはRelaxed memory modelを採用する
* データ競合のないプログラムに対してDRF-SC保証を持つ
* プログラムの一部にデータ競合がない場合（他の部分にデータ競合があったとしても）、その部分に対してDRF-SC保証を持つ
* データ競合があったとしても、プログラムがクラッシュすることはない

# 参考

* [4 Memory Model: The easy bits](https://v2.ocaml.org/releases/5.0/manual/parallelism.html#s:par_mm_easy)
* [Chapter 10 Memory Model: The hard bits](https://v2.ocaml.org/releases/5.0/manual/memorymodel.html#c%3Amemorymodel)
