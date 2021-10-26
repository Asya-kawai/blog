# Emacsのソースビルドで困った時のTips

Emacsのソースビルドでエラーが発生した際に役立ちそうなメモを残す。

## makeがエラーとなる

Emacsのソースビルドでエラーとなる箇所を特定し、それがもし`bootstrap`関連である場合は、
下記コマンドを実行し`bootstrap`だけを先にビルドすると通ることがある。

```
make clean
make bootstrap
make
sudo make install
```

## 最新版でエラーとなる

github.com のmasterブランチを利用していてエラーとなる場合は、安定バージョンを指定することで回避できる場合がある。

例えば、最新のEmacs29でエラーとなっている場合、Emacs 28（安定版）ブランチに切り替えてビルドをすることで回避できる。

```
git clone https://github.com/emacs-mirror/emacs.git
git fetch
git checkout emacs-28
git branch

./autogen.sh
./configure --with-native-compilation
make clean
make
sudo make install
```
