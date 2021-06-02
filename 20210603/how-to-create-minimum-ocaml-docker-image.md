# 最も小さいOCamlのDockerコンテナイメージの作り方

OCamlではかつて`jbuilder`というビルドツールが利用されていた。

しかし2018年以降は`dune`というプロジェクトに変わったため、
`dune`でアプリケーションを構築し且つ最小のDockerコンテナイメージを生成する方法を示す。

参照: [dune migration](https://dune.readthedocs.io/en/latest/migration.html?highlight=Jbuilder#migration)

## opamのインストール

`opam`はOCamlのパッケージ管理ツールである。

OCamlのライブラリ（モジュール）や`dune`などのツールをインストールにはこれを利用するため、
予めインストールしておく。

以下のコマンドを実行し`opam`をインストールする。

なお、インストール先の環境は`Ubuntu 20.04`となっている。

```
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
```

参照: [How to install opam](https://opam.ocaml.org/doc/Install.html)

次に初期化処理を行う。

```
opam init
```

`opam init`を実行した際、以下のように推奨パッケージを要求される場合がある。

```
root@90e8251e3431:/# opam init
[WARNING] Running as root is not recommended
[NOTE] Will configure from built-in defaults.
Checking for available remotes: none.
  - you won't be able to use rsync and local repositories unless you install the rsync command on your system.
  - you won't be able to use git repositories unless you install the git command on your system.
  - you won't be able to use mercurial repositories unless you install the hg command on your system.
  - you won't be able to use darcs repositories unless you install the darcs command on your system.

[WARNING] Recommended dependencies -- most packages rely on these:
  - make
  - m4
  - cc
[ERROR] Missing dependencies -- the following commands are required for opam to operate:
  - patch
  - unzip
  - bwrap: Sandboxing tool bwrap was not found. You should install 'bubblewrap'. See https://opam.ocaml.org/doc/FAQ.html#Why-does-opam-require-bwrap.
```

上記の案内に従ってパッケージ群をインストールする。

```
apt install git hg darcs rsync pkg-config make m4 gcc patch unzip bubblewrap
```

インストールが完了したら、改めて`opam init`を実行する。

以下のように設定ファイルを上書きするかどうかを求められる場合があるが、
初めて利用する場合は`yes`を選択しておけばよい。

```
Do you want opam to modify ~/.profile? [N/y/f]
(default is 'no', use 'f' to choose a different file) y
A hook can be added to opam's init scripts to ensure that the shell remains in sync with the opam environment when they are loaded. Set that up? [y/N] y
```

なお、`opam init` では`default`というスイッチが作成される。
スイッチとは、コンパイラ及びパッケージ群を１つのまとまりと管理するための`opam`の機構である。

これ有効にするためには、`eval $(opam env)`を求められる場合があるため、その際はこのコマンドを実行する。

### プロジェクト毎に異なるパッケージを利用するための設定

OCamlには様々なバージョンがあり、いくつかのバージョンを使い分けたいケースもある。

その場合、`opam switch`というコマンドを利用し、コンパイラ及びパッケージ群を１つのまとまり（スイッチと呼ぶ）に集約できる。

例えば、以下のコマンドを実行すると、コンパイラ4.12.0を利用する`my-app`というスイッチを作成できる。

```
opam switch create my-app ocaml-base-compiler.4.12.0
```

作成したスイッチは`opam switch`コマンドで確認できる。その例を以下に示す。

```
opam switch
#   switch   compiler                    description
    default  ocaml-base-compiler.4.12.0  default
->  my-app   ocaml-base-compiler.4.12.0  my-app
```

参照: [opam switch](https://opam.ocaml.org/doc/man/opam-switch.html)

## OCamlアプリケーションの作成

まずは、OCamlでアプリケーション開発のためのビルドツール`dune`をインストールする。
その他、本稿ではWebアプリケーションを開発する予定であるため、
Webアプリケーションに必要なライブラリ（モジュール）も合わせてインストールする。

```
opam install dune lwt cohttp-lwt-unix
```

`dune`を利用するためには、`dune`という設定ファイルを利用する。

通常利用の場合は、実行ファイル名や利用するライブラリを記載するだけでよいが、
今回はDockerコンテナで利用することを想定するため、静的リンクでバイナリを構成するよう指定する必要がある。

参照: [dune quickstart](https://dune.readthedocs.io/en/stable/quick-start.html)

本稿では`main`というアプリケーション名で生成することにする。

以下に、`dune`ファイルの内容を示す。

```
;; https://discuss.ocaml.org/t/linking-several-so-libraries-produced-by-dune/6133
(executable
 (name main)
 (link_flags :standard -linkall)
 (libraries lwt cohttp-lwt-unix)
)
```

次にアプリケーション本体を作成する、

本稿では、`cohttp`ライブラリ（モジュール）を利用しサンプルアプリケーションを作成する。

アプリケーションファイル名を`main.ml`とし、以下の内容で作成する。

```
open Lwt
open Cohttp
open Cohttp_lwt_unix

let server =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    ( body |> Cohttp_lwt.Body.to_string >|= fun body ->
      Printf.sprintf "Uri: %s\nMethod: %s\nHeaders\nHeaders: %s\nBody: %s" uri
        meth headers body )
    >>= fun body -> Server.respond_string ~status:`OK ~body ()
  in
  Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)
```

参照: [cohttp basic server tutorial](https://github.com/mirage/ocaml-cohttp#basic-server-tutorial)

バイナリファイルが動作するかどうかは、以下のいづれかのコマンドで確認できる。

```
dune build main.exe
```

または、

```
_build/default/main.exe
```

## Dockerfileの作成

次に`Dockerfile`を作成する。

Dockerコンテナはマルチステージビルドに対応させるため３つのステージに分けることにした。

以下に各ステージとその役割を示す。

* init-opam
  * opamが同梱されたコンテナイメージのパッケージを最新にするステージ
* ocmal-app-base
  * アプリケーションのビルドに必要なパッケージの導入及びアプリケーションのビルドを行うステージ
* ocaml-app
  * ocaml-app-baseで作成したバイナリファイルを最小コンテナイメージ内にコピーしエントリポイントを設定するステージ

上記のステージを構成するための`Dockerfile`の内容を以下に示す。

```
FROM ocaml/opam:alpine AS init-opam

RUN set -x && \
    : "Update and upgrade default packagee" && \
    sudo apk update && sudo apk upgrade && \
    sudo apk add gmp-dev

# --- #

FROM init-opam AS ocaml-app-base
COPY . .
RUN set -x && \
    : "Install related pacakges" && \
    opam install -y dune lwt cohttp-lwt-unix yojson && \
    eval $(opam env) && \
    : "Build applications" && \
    dune build main.exe && \
    sudo cp ./_build/default/main.exe /usr/bin/main.exe

# --- #

FROM alpine AS ocaml-app

COPY --from=ocaml-app-base /usr/bin/main.exe /home/app/main.exe
RUN set -x && \
    : "Create a user to execute application" && \
    adduser -D app && \
    : "Change owner to app" && \
    chown app:app /home/app/main.exe

WORKDIR /home/app
USER app
ENTRYPOINT ["/home/app/main.exe"]
```

この`Dockerfile`と前章で作成した`dune`ファイル、`main.ml`を同一ディレクトリに配置する。

```
Dockerfile dune main.ml
```

そして、`docker build .`コマンドを実行し、Dockerコンテナイメージを作成する。

今回は `docker build --tag 20210530-ocaml-micro-service .`で実行し、
Dockerコンテナイメージのタグに20210530-ocaml-micro-serviceという名称をつけた。

ビルド後のイメージサイズは25MBで、かなり小さいコンテナイメージとなった。

```
docker images
REPOSITORY                                        TAG       IMAGE ID       CREATED        SIZE
20210530-ocaml-micro-service                      latest    589420cffa3a   3 days ago     25MB
```

## まとめ

OCamlアプリケーションを作成する際に役立つ、opamやduneなどの便利なツールを利用すると効率よく開発できる。

その際にDockerイメージ内にopamやduneといったツールを含めてしまうとイメージサイズが大きくなり、
本来アプリケーションに必要でないものまでインストールされた状態となってしまう。

そこでマルチステージビルドを利用し、ビルド前まではopamやduneなどの便利ツールを利用しつつ。
最終的にはalpineなどの軽量OSにアプリケーションのみデプロイすることで最小イメージの作成に成功した。
