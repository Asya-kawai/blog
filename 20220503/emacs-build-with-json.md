# Emacsのlsp-modeを高速化するためにjsonパーサを有効にする

Emacsでtypescriptを書いていて、lspが非常に重いので、チューニングを決意。

[EmacsのLSP-modeの動作を軽くする](https://www.zeroclock.dev/posts/2020/07/emacs-lsp-mode-more-faster/)
を参考に、まずは`M-x lsp-diagnose`を利用して、`lsp-mode`の状態をチェックする。

```
Checking for Native JSON support: ERROR
Check emacs supports `read-process-output-max': OK
Check `read-process-output-max' default has been changed from 4k: ERROR
Byte compiled against Native JSON (recompile lsp-mode if failing when Native JSON available): ERROR
`gc-cons-threshold' increased?: OK
Using gccemacs with emacs lisp native compilation (https://akrl.sdf.org/gccemacs.html): OK
```

Native JSON はEmacsに組み込まれたJSONパーサのことで、これを利用すると高速化するみたいなので、
ソースコードをダウンロードしビルドを行う。

```
git clone https://github.com/emacs-mirror/emacs.git
git fetch
git checkout emacs-28
git branch

./autogen.sh
./configure --with-native-compilation --with-mailutils --with-json
```

ビルドの出力に下記の行が出現していることを確認する。


```
 Does Emacs use -ljansson? yes
```

もしなければ、`sudo apt install libjansson-dev`を実行後、もう一度`./configure --with-native-compilation --with-mailutils --with-json`を試してみる。

`--with-json`が有効であれば、下記コマンドでインストールする。

```
make clean
make
sudo make install
```

Emacsを起動し、lsp-modeの状態を確認しNative json supportが`OK`になっていることを確認する。

```
Checking for Native JSON support: OK
Check emacs supports `read-process-output-max': OK
Check `read-process-output-max' default has been changed from 4k: ERROR
Byte compiled against Native JSON (recompile lsp-mode if failing when Native JSON available): OK
`gc-cons-threshold' increased?: ERROR
Using gccemacs with emacs lisp native compilation (https://akrl.sdf.org/gccemacs.html): OK
```

残りのエラーは、`gc-cons-threshold`を変更することで`OK`となる。

具体的には、`M-x eval-expression` の後で、`(setq gc-cons-threshold 1600000) `というように設定する。

今の段階では最適な値は見つかっていないので割愛。

# 参考
* [EmacsのLSP-modeの動作を軽くする](https://www.zeroclock.dev/posts/2020/07/emacs-lsp-mode-more-faster/)
* https://github.com/flycheck/flycheck/issues/1471
