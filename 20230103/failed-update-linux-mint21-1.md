# Linux Mint 21.1 のアップデートが失敗？する

2023/01/03現在、Linux Mint 21.1 vera へアップデートした際、`apt update`で一部が無視されるようになった。

```
% LANG=C sudo apt update
Hit:1 https://download.docker.com/linux/ubuntu jammy InRelease
Hit:2 http://dl.google.com/linux/chrome/deb stable InRelease
Hit:3 http://packages.microsoft.com/repos/code stable InRelease
Get:4 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Hit:5 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:6 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [114 kB]
Hit:7 https://ppa.launchpadcontent.net/git-core/ppa/ubuntu jammy InRelease
Get:8 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [99.8 kB]
Get:9 http://archive.ubuntu.com/ubuntu jammy-updates/main i386 Packages [393 kB]
Get:10 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [768 kB]
Ign:11 http://packages.linuxmint.com vera InRelease
Hit:12 http://packages.linuxmint.com vera Release
Fetched 1,486 kB in 5s (298 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
```

上記の`Ign:11 http://packages.linuxmint.com vera InRelease`の部分である。

## 環境の確認

手元の環境で利用しているレポジトリ等の情報は以下の通り。

```
% inxi -Sr
System:
  Host: aoi-local Kernel: 5.15.0-56-generic x86_64 bits: 64
    Desktop: Cinnamon 5.6.5 Distro: Linux Mint 21.1 Vera
Repos:
  No active apt repos in: /etc/apt/sources.list
  Active apt repos in: /etc/apt/sources.list.d/docker.list
    1: deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable
  Active apt repos in: /etc/apt/sources.list.d/git-core-ppa-jammy.list
    1: deb [arch=amd64 signed-by=/etc/apt/keyrings/git-core-ppa-jammy.gpg] https://ppa.launchpadcontent.net/git-core/ppa/ubuntu jammy main
  Active apt repos in: /etc/apt/sources.list.d/google-chrome.list
    1: deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
  Active apt repos in: /etc/apt/sources.list.d/official-package-repositories.list
    1: deb http://packages.linuxmint.com vera main upstream import backport
    2: deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
    3: deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
    4: deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
    5: deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
  Active apt repos in: /etc/apt/sources.list.d/vscode.list
    1: deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable ma
```

無視されたレポジトリのファイル内容も念の為確認してみる。

```
% cat /etc/apt/sources.list.d/official-package-repositories.list
deb http://packages.linuxmint.com vera main upstream import backport #id:linuxmint_main

deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
```

この一番上の行が問題みたいだ。

## Ignが本当に問題なのか確認する

`apt update`をよく見てみると以下のように`import backport`によって成功していることがわかる。

```
Ign:11 http://packages.linuxmint.com vera InRelease
Hit:12 http://packages.linuxmint.com vera Release
```

2023/01/03現在、`import backport`があれば、Linux Mint 21.1のパッケージアップデートは問題なく行えることがわかった。

# まとめ

OSが参照するレポジトリファイル`/etc/apt/sources.list.d/official-package-repositories.list`に以下の行が含まれていることを確認する。

```
deb http://packages.linuxmint.com vera main upstream import backport #id:linuxmint_main
```

これが含まれていればアップデートが問題なく行える。

# 参考

* [Failed update to Linux Mint 21.1](https://forums.linuxmint.com/viewtopic.php?t=387951)
