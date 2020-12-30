# Emacsでいい感じに vue.js + Typescript やる設定

きっかけは、これ。
[EmacsにおけるTypescript + React JSXの苦悩と良さげな設定について](https://qiita.com/nuy/items/ebcb25ad14f02ab72790)


vue.js + Typecript の場合は、どのような設定が適切なんだろうってなったので。

## 概要

Emacsで vue.js を書く際に、`vue-mode` を利用するのが楽。

ここで、vue.js と `Typescript` を併用するケースを考える。

`vue-mode` だけでは `typescript-mode` の恩恵を受けることが出来ないため、`mmm-mode` を利用するのが一般的（だと思う）。

この時、`<script lang="ts">` なケースだけ `typescript-mode` を有効にする方法を知ったので共有する。

# 設定

いきなり結論だが、自分が達した設定は以下の通り。

```
;;; --- vue mode
(use-package vue-mode
  :ensure t
  :hook ((vue-mode . company-mode)
         (vue-mdoe . flycheck-mode)
         (vue-mode . eldoc-mode)
         (vue-mode . lsp-deferred))
  :config
  (setq js-indent-level 2)
  (setq css-indent-offset 2))
(use-package mmm-mode
  :ensure t
  :hook ((mmm-mode . company-mode)
         (mmm-mdoe . flycheck-mode)
         (mmm-mode . eldoc-mode))
  :config
  ;; (set-face-background 'mmm-default-submode-face "gray13")
	(setq indent-tab-mode nil)
  (setq mmm-submode-decoration-level 2)
  (setq tab-width 2)

  ;; Note: Should check by ESC-x regexp-builder.
  (mmm-add-classes
   '((vue-embeded-web-mode
      :submode vue-mode
      :front "^<template>\n"
      :back "</template>")
     (vue-embeded-js-mode
      :submode js-mode
      :front "^<script>\n"
      :back "^</script>")
     (vue-embeded-typescript-mode
      :submode typescript-mode
      :front "^<script.*lang=\"ts\".*>\n"
      :back "^</script>")
     (vue-embeded-css-mode
      :submode vue-mode
      :front "^<style>\n"
      :back "^</style>")
     (vue-embeded-scss-mode
      :submode scss-mode
      :front "^<style.*lang=\"scss\".*>"
      :back "^</style>")))

  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-web-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-js-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-typescript-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-css-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-scss-mode))

;; Fix js-mode and typescript-mode indent into mmm-mode(vue-mode).
;; Reference: https://github.com/AdamNiederer/vue-mode/issues/74#issuecomment-539711083
(setq mmm-js-mode-enter-hook (lambda () (setq syntax-ppss-table nil)))
(setq mmm-typescript-mode-enter-hook (lambda () (setq syntax-ppss-table nil)))

;;; --- typescript mode
(use-package typescript-mode
  :ensure t
  :config
  (setq typescript-indent-level 2)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode)))
;; need to install company and tide.
(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (typescript-mode . company-mode)
         (typescript-mdoe . flycheck-mode)
         (typescript-mode . eldoc-mode)
         (typescript-mode . lsp-deferred)
         (before-save . tide-format-before-save))
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))
```
## 解説

### vue-mode

```
;;; --- vue mode
(use-package vue-mode
  :ensure t
  :hook ((vue-mode . company-mode)
         (vue-mdoe . flycheck-mode)
         (vue-mode . eldoc-mode)
         (vue-mode . lsp-deferred))
  :config
  (setq js-indent-level 2)
  (setq css-indent-offset 2))
```

特に言及することはないかな？

`js` と `css` のセクションのインデントを2に設定したくらい。


### mmm-mode

```
(use-package mmm-mode
  :ensure t
  :hook ((mmm-mode . company-mode)
         (mmm-mdoe . flycheck-mode)
         (mmm-mode . eldoc-mode))
  :config
  ;; (set-face-background 'mmm-default-submode-face "gray13")
  (setq indent-tab-mode nil)
  (setq mmm-submode-decoration-level 2)
  (setq tab-width 2)

  ;; Note: Should check by ESC-x regexp-builder.
  (mmm-add-classes
   '((vue-embeded-web-mode
      :submode vue-mode
      :front "^<template>\n"
      :back "</template>")
     (vue-embeded-js-mode
      :submode js-mode
      :front "^<script>\n"
      :back "^</script>")
     (vue-embeded-typescript-mode
      :submode typescript-mode
      :front "^<script.*lang=\"ts\".*>\n"
      :back "^</script>")
     (vue-embeded-css-mode
      :submode vue-mode
      :front "^<style>\n"
      :back "^</style>")
     (vue-embeded-scss-mode
      :submode scss-mode
      :front "^<style.*lang=\"scss\".*>"
      :back "^</style>")))

  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-web-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-js-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-typescript-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-css-mode)
  (mmm-add-mode-ext-class nil "\\.vue\\'" 'vue-embeded-scss-mode))
```

`config` については特に言及ないかな？

最初は [EmacsでVueファイルを編集するときの設定](https://qiita.com/pagu_o28/items/ff4034d350077b583820) 
を参考に `mmm-default-submode-face` を設定していたが、自分は不要かなと。

多色じゃない方が自分は好きなので。


`mmm-add-classes` と `ext-class` について。

`mmm-add-classes` にて、任意のクラスを `mmm-classes-alist` に追加し、
それらを `mmm-add-mode-ext-class` にて `mmm-mode-ext-classes-alist` に追加している。

こうすることで、自身で定義したサブモードが `mmm-mode` にて有効になる。

自身で定義したサブモードについてだが、 `:front` はサブモード開始の文字列を表し、
`:back` はサブモード終了の文字列を表す。

なお、自分の場合は、`<style lang="csss" scoped>` など、
styleセクションにてlangがどの位置であっても対応可能なように `:front` を設定した。


### jsのインデント崩れ対応

次の設定を入れないと `vue-mode` のjsセクションにて適切なインデントにならなかったので設定。

```
(setq mmm-js-mode-enter-hook (lambda () (setq syntax-ppss-table nil)))
(setq mmm-typescript-mode-enter-hook (lambda () (setq syntax-ppss-table nil)))
```

[Emacs 26.3 で vue-mode の js パートのインデントが効かなくなる件の対処法](https://qiita.com/akicho8/items/58c2ac5d762a2a4479c6)
を参考にした。

### Typescript-mode

```
;;; --- typescript mode
(use-package typescript-mode
  :ensure t
  :config
  (setq typescript-indent-level 2)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode)))
;; need to install company and tide.
(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (typescript-mode . company-mode)
         (typescript-mdoe . flycheck-mode)
         (typescript-mode . eldoc-mode)
         (typescript-mode . lsp-deferred)
         (before-save . tide-format-before-save))
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))
```

ここも `vue-mode` 同様に特に言及することは特にないかな？

Emacs にて、 `typescript` を書く時は、[tide](https://github.com/ananthakumaran/tide) を利用すると吉。

この `tide` の設定もどこかを参考に色々設定したんだが、昔のことで忘れてしまった。

### 全体の設定

自身の `init.el` は[こちら](https://github.com/Asya-kawai/emacs_settings)。

全体が見たい方はどうぞ（ `lsp` 周りを解説していないので、分からなければ参考に）。

# 課題

* 各セクションの先頭だけ、なぜかインデントが2下げとなってしまう

# 参考

* [EmacsにおけるTypescript + React JSXの苦悩と良さげな設定について](https://qiita.com/nuy/items/ebcb25ad14f02ab72790)
* [EmacsでVueファイルを編集するときの設定](https://qiita.com/pagu_o28/items/ff4034d350077b583820) 
* [Emacs 26.3 で vue-mode の js パートのインデントが効かなくなる件の対処法](https://qiita.com/akicho8/items/58c2ac5d762a2a4479c6)
* https://github.com/AdamNiederer/vue-mode/issues/74#issuecomment-539711083
