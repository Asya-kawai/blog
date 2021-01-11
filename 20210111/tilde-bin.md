# ~(チルダ)bin には気をつけよう

`~bin` ってのがあって、
あれ？間違って作ったかなって思って `rm -rf ~bin` ってやったら、
`root` の持ち物で、あれ？間違ってコピーしたんかな？って思って `sudo rm -rf ~bin` したら `/bin` が消えちゃった...

`dirname ~bin` ってやると、`/` 
が返ってきましたね。

`~bin` は `/bin` だったんですね〜（いやー知らなかった

# 環境

自分の環境でしか試していないので、他のOSでは未確認。

一応、作業した環境は以下の通り。

* OS: Linux Mint 19.2 Tina 
* kernel: 4.15.0-54-generic x86_64


# 対応

`/bin` の戻し方は色々あると思うんですが、dockerコマンド入れている環境であれば最速なんじゃないかな、という手法をば。

ざっくりとした手順は以下の通り。

* `/bin` を復旧
* 足りないパッケージを`dpkg` にてインストール

の2つ。

## Docker image から /bin をコピーする

Linux mint は ubuntu ベースのOSなので、ubuntuのdockerイメージから`bin`をコピーする。

```
docker run -i ubuntu:18.04
```

ubuntuイメージの `CONTAINER ID` を確認する。

```
docker ps
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                          NAMES
a315872a25bb        ubuntu:18.04                "/bin/bash"              58 minutes ago      Up 58 minutes                                      nostalgic_joliot
```

上記 `CONTAINER ID` を下記コマンドで指定し、ホストのテキトーなディレクトリ（ここでは `bin-tmp` とした）にコピー。

```
docker cp a315872a25bb:/bin /home/toshiki/bin-tmp
```

その後、持ち主を`root`に変え、`/bin` にコピーする。

```
sudo /home/toshiki/bin-tmp/chown -R root:root /home/toshiki/bin-tmp/*
sudo /home/toshiki/bin-tmp/cp -a /home/toshiki/bin-tmp /bin
```

この後でちゃんとdpkg等で必要なパッケージインストールしてあげないと、systemdとか入ってこない。

次の手順にてdpkg経由で足りないパッケージをインストールする。

## 足りないパッケージのインストール

不足しているパッケージについては、`apt` 等のパッケージ管理ツールで導入したものがほとんどだろう。

そこで、`/bin` 以下にインストールされた（されたはず）のパッケージをリストアップする。

```
dpkg --search /bin | cut -f1 -d: | tr ',' '\n' > pkg.list
```

一時的なディレクトリを作成し、リストからパッケージファイルをダウンロードｓる。

```
mkdir tmp
cp pkg.list tmp/.
cd tmp
cat pkg.list | xargs -I{} apt download {}
```

最後に、上記にて取得したパッケージを全てインストールし（カレントディレクトリの `bin` に入る）、
これらを `/bin` にコピーしてあげれば良い。

```
for i in $(ls *.deb); do dpkg-deb -x $i . ; done
sudo cp -a ./bin/* /bin/.
```

# 追記

`bin` 内のプログラムをコピーする際に、最初は `cp -r` でやっていたんだけど、@hiroseyuuji 先生にハードリンクがうまくコピーできない点をご指摘頂いて、
`cp -r` を `cp -a` に修正。

# 参考

* [Accidentally removed /bin. How do I restore it?](https://askubuntu.com/questions/906674/accidentally-removed-bin-how-do-i-restore-it)
