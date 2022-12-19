# SATySFiを用いて同人誌を書いた話

2022/11/20に開催された[第七回 技術書同人誌博覧会](https://gishohaku.dev/)に出展する同人誌を[SATySFi](https://github.com/gfngfn/SATySFi)を用いて執筆した。

[The SATySFi book](https://booth.pm/ja/items/1127224)で用いられるテーマ（クラス）が好みであったため、gihtubにある[ソースコード](https://github.com/gfngfn/the_satysfibook)からbook-class.satyhをコピーし利用させてもらった。

## 書きっぷりについて

LaTex等の組版システム扱ったものであれば、（文法は違えど）その使用感をすんなり受け入れることができると感じた。

なお、プリミティブや文法等については The SATySFi book を参照されたい。

また、強力な型システムによって不適切な入力を早期エラーとして報告する仕組みや、拡張性の高いコマンド定義が可能である点も嬉しかった。

## 独自のテーマを利用した際につまづいた点について

book-class.satyhをコピーし独自拡張して利用したが故に、目次にハイパーリンクが付くような機能を実装していなかった。

そのため、電子書籍の目次をクリックして当該の章や節にジャンプする機能がなかったのだ。

SlackのSATySFiコミュニティ`satysfi.slack.com`で質問をしたところ、ハイパーリンクを付けるためのプリミティブが用意されていることが分かったため、これを利用することにした。

[PDFハイパーリンク - コマンド・クラスファイル作成者向け](https://github.com/gfngfn/SATySFi/wiki/PDF%E3%83%8F%E3%82%A4%E3%83%91%E3%83%BC%E3%83%AA%E3%83%B3%E3%82%AF#%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%82%AF%E3%83%A9%E3%82%B9%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E4%BD%9C%E6%88%90%E8%80%85%E5%90%91%E3%81%91)

例えば、Chapterに関するコマンド定義については、

```
  let chapter-scheme ctx label title inner =
  ...
  let bb-title = chapter-heading key-pdf-loc ctx (Some(ib-num)) ib-title in
  ...
```

となっていたところを、

```
  let chapter-scheme ctx label title inner =
  ...
  let bb-title =
    let bb = line-break false false ctx (inline-frame-breakable no-pads (Annot.register-location-frame label) (location-frame key-pdf-loc (ib-num ++ inline-fil ++ ib-title ++ inline-fil))) in bb +++ block-skip 36pt in
  ...
```
のように、`annot`パッケージの`register-location-frame`を用いてChapterへのジャンプ先を`label`で登録するようにした。

次に目次を生成するコマンドである`bb-toc`について

```
    % -- table of contents --
    let bb-toc =
    ...
    | TOCElementChapter(label, title) ->
      ...
      (ib-title ++ ib-middle ++ ib-page)
```

となっていたところを、

```
    % -- table of contents --
    let bb-toc =
    ...
    | TOCElementChapter(label, title) ->
      ...
      (inline-frame-breakable no-pads (Annot.link-to-location-frame label None) (ib-title ++ ib-middle ++ ib-page))
```

`annot`パッケージの`link-to-location-frame`を用いてChapterへのジャンプ先である`label`を指定すれば、目次にハイパーリンクを付けることができる。

同様に`register-location-frame`と`link-to-location-frame`を用いて、目次のSection（SubSectionを含む）にハイパーリンクを付けることが可能だ。

具体的なソースコードは[Github.com - Basic-of-programming-on-ocaml](https://github.com/Asya-kawai/basic-of-programming-on-ocaml)の`book-class.satyh`を参照されたい。

# まとめ

SATySFiの利用例はいくつか知っていたが、自身の成果物のために利用したのは初めてだった。

しかしThe SATySFi bookで基本を学び、コミュニティの方々の強力を得ることで同人誌1冊を書き上げることができた。

書くことはもちろん、自身でクラスファイルを作成し育てていく楽しみもSATySFiの魅力だと感じた。
