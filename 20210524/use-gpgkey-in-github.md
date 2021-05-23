# GPGキーを利用してCommitに署名する方法

Gitを利用する場合、
任意のユーザがCommitを作成でき且つ
そのユーザが別の任意のユーザであると主張（なりすます）ことが可能である。

例えば、悪意のある第三者が `git config user.name`と
`git config user.email`を利用して任意のユーザになりすますことが可能となる。

この場合、以下の2点を保証することができない。

1. Commitの作成者が本人であること
1. Commitの改ざんがないこと

そこで、GPGキーを用いたCommitへの署名という機能がある。

以下では、その手順を示す。

## GPGキーを利用したCommit署名の設定

[新しい GPG キーを生成する](https://docs.github.com/ja/github/authenticating-to-github/managing-commit-signature-verification/generating-a-new-gpg-key)に従って、GPGキーを作成する。  
以下に具体的な手順を示す。

GPGキーペアを作成するために以下のコマンドを入力する。

```
$ gpg --full-generate-key

gpg (GnuPG) 2.2.19; Copyright (C) 2019 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

ご希望の鍵の種類を選択してください:
   (1) RSA と RSA (デフォルト)
   (2) DSA と Elgamal
   (3) DSA (署名のみ)
   (4) RSA (署名のみ)
  (14) カードに存在する鍵
あなたの選択は? 1

RSA 鍵は 1024 から 4096 ビットの長さで可能です。
鍵長は? (3072) 4096
要求された鍵長は4096ビット

鍵の有効期限を指定してください。
         0 = 鍵は無期限
      <n>  = 鍵は n 日間で期限切れ
      <n>w = 鍵は n 週間で期限切れ
      <n>m = 鍵は n か月間で期限切れ
      <n>y = 鍵は n 年間で期限切れ
鍵の有効期間は? (0)
鍵は無期限です

これで正しいですか? (y/N) y

GnuPGはあなたの鍵を識別するためにユーザIDを構成する必要があります。

本名: XXXXXXXXXXX
電子メール・アドレス: XXXXXXXXXXXX@aintek.xyz
コメント: GitHub GPG key
```
その後、パスフレーズを入力する。

鍵を作成後、GPGキーのリストを表示、上記で作成したキーIDを取得する。

```
$ gpg --list-secret-keys --keyid-format LONG
/Users/hubot/.gnupg/secring.gpg
------------------------------------
sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
uid                          Hubot 
ssb   4096R/42B317FD4BA89E7A 2016-03-10
```

上記の例では、GPG キー ID は`3AA5C34371567BD2`となる。

その後、下記コマンドにて秘密鍵を標準出力に表示する。

```
$ gpg --armor --export 3AA5C34371567BD2
```

表示された内容をコピーし、[GitHub アカウントへの新しい GPG キーの追加](https://docs.github.com/ja/github/authenticating-to-github/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account)
に従ってGPGキーを登録する。  
具体的な手順はリンクを参照されたい。

次にGitでGPGキーを設定するため以下のコマンドを実行する。

```
$ git config --global user.signingkey 3AA5C34371567BD2
```

さて、GPGキーの作成及び登録ができたので、Gitクライアントにてこれを利用する設定を行う。
[コミットに署名する](https://docs.github.com/ja/github/authenticating-to-github/managing-commit-signature-verification/signing-commits)に従って、コマンドを実行する。  
具体的な手順を以下に示す。

手元のリポジトリでデフォルトでコミットに署名を付与する場合は以下のコマンドを実行する。

```
$ git config commit.gpgsign true
```

また、手元のコンピュータの全てのリポジトリにおけるコミットにて署名を付与する場合は以下のコマンドを実行する。


```
$ git config --global commit.gpgsign true
```

後は、リポジトリにてコミットする際に以下のコマンドを実行すればGPGキーによる署名付きコミットとなる。

```
$ git commit -S -m "your commit message"
```


# 参考

* [How(and Why) to sign Git commits](https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html)
* [新しい GPG キーを生成する](https://docs.github.com/ja/github/authenticating-to-github/managing-commit-signature-verification/generating-a-new-gpg-key)
* [GitHub アカウントへの新しい GPG キーの追加](https://docs.github.com/ja/github/authenticating-to-github/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account)
* [gpg failed to sign the data fatal: failed to write commit object [Git 2.10.0]](https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0)
