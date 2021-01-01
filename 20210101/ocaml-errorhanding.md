# OCamlのエラーハンドリングについて

下記で結構議論されている。

* [Exception vs Result](https://discuss.ocaml.org/t/exception-vs-result/6931)

議論の元になった記事は [On Effectiveness of Exceptions in OCaml](https://lemaetech.co.uk/articles/exceptions.html) で、
少し前にOCaml界隈で `reuslt型` が持て囃されたんだけど、それに対して「ここがイケていない！」っていう点を書いたブログ。

んで、このトピックは「そんなことないよ」って反論したもの（だと思う）。

スレッドもかなり長くて現時点では結論が見えないんだけど、個人的には `reuslt型` も 例外もいい感じに使っていこうぜってなっている。

[ここ](https://discuss.ocaml.org/t/exception-vs-result/6931/9) 参考。


まぁこの辺は割と昔から議論されているよね〜ってことでもちっと古い記事だと[これ](https://keleshev.com/composable-error-handling-in-ocaml)とか。


# 参考

* [Exception vs Result](https://discuss.ocaml.org/t/exception-vs-result/6931)
* [On Effectiveness of Exceptions in OCaml](https://lemaetech.co.uk/articles/exceptions.html)
* [Composable Error Handling in OCaml](https://keleshev.com/composable-error-handling-in-ocaml)
