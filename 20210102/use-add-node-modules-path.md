# add-node-modules-path の設定

js周りの開発をしていると、
グローバルに入れたくないコマンドやライブラリは
基本的に各プロジェクト配下の `node_modules` に入れると思う。

Emacsで開発する場合、特に何も設定しなければ
プロジェクト配下の `node_modules/.bin/` にパスが通らないため、
このディレクトリにあるコマンド等が利用できない。

まぁ、自分でlisp書いて設定してもいいんだけど、
便利なパッケージを作ってくれている方はいるようなのでありがたく使わせてもらう。

* [add-node-modules-path](https://github.com/codesuki/add-node-modules-path)

`init.el` の設定は以下の通り。

以下では例として、`vue-mode` での設定をあげる。

```
;;; --- vue mode
(use-package add-node-modules-path
  :ensure t
  :commands add-node-modules-path)
(use-package vue-mode
  :ensure t
  :hook ((vue-mode . add-node-modules-path)))
```

`use-package` にて、各種パッケージをインストールし、
`add-modules-path` を利用したいモードにHookする。

外部のパッケージが気に入らなければ、[add-node-modules-path](https://github.com/codesuki/add-node-modules-path) 
を参考に自身で作成してみてもいいだろう。

# 参考

* [add-node-modules-path](https://github.com/codesuki/add-node-modules-path) 
