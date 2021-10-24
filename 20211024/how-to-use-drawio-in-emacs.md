# Emacsで draw.io を利用する方法

[draw.io](https://drawio-app.com/tutorials/interactive-tutorials/)はダイアグラムを容易に作成・編集できるサービスである。

draw.io はブラウザ及びデスクトップアプリケーションで利用可能であり、VSCodeの拡張も存在する。

一方、Emacsでは draw.io に関する拡張はまだない。
そこで、Emacsで draw.io を利用するための方法を紹介する。

## Emacsで draw.io を表示する

一から draw.io のUIを模したものを作成するのは困難であるため、まずはブラウザ版の draw.io をEmacsに表示することにした。

Emacs上にブラウザ画面を描写するには、`webkit`を利用する必要がある。

Ubuntuであれば、以下のようにインストールする。

```
sudo apt update
sudo apt install libwebkit2gtk-4.0-dev
```

また、Emacsの[ネイティブコンパイル](https://www.emacswiki.org/emacs/GccEmacs)によって起動速度を向上させたい場合は、下記パッケージもインストールする。

```
sudo apt libgccjit-9-dev
```

次にEmacsのソースコードをGithubからダウンロードする。

```
git clone https://github.com/emacs-mirror/emacs.git
cd emacs
```

下記コマンドを実行して、ビルド及びインストールする。


`--with-native-compilation`はネイティブコンパイルのためのオプションであり、
`--with-xwidgets`はwebkitを利用するためのオプションである。
なお、`--with-mailutils`はWarningを回避するために追加した。

```
./autogen.sh
./configure --with-native-compilation --with-xwidgets --with-mailutils
make clean
make
sudo make install
```

確認のため、下記コマンドを実行しEmacsを起動してみる。

`-q`は設定ファイルを読み込まないためのオプションである。

```
emacs -q
```

`M-x xwidget-webkit-browse-url`を入力して、`https://app.diagrams.net/` を入力するとEmacs上で draw.io を利用することができる。

## Emacsからブラウザ版の draw.io を起動する

Emacsのバージョンやwebkitのバージョン、その組み合わせによっては、うまく動作しない場合があると思われる。

その場合は、Emacsからブラウザ版の draw.io を起動することをおすすめする。

`M-x browse-url` を入力後、`https://app.diagrams.net/` を入力すればEmacsからブラウザ版 draw.io を起動できる。
