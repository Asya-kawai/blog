# Nuxt.js + Typescript の環境構築（手動）

* npm update
* npm 
* npm install @nuxt/typescript-build

# ついでに composition api も

* npm install @nuxtjs/composition-api

## 画像で躓く

画像をimportする際は、モジュールの型を定義しておく。

https://qiita.com/babie/items/25aa63e14c06e4a9a046

これを参考に、`vue-shim.d.ts` に定義した。

# eslint も

* https://typescript.nuxtjs.org/ja/guide/lint/

# 参考

* https://typescript.nuxtjs.org/ja/guide/setup/
* https://techblog.zozo.com/entry/vue-options-api-to-composition-api
* https://qiita.com/babie/items/25aa63e14c06e4a9a046
* https://typescript.nuxtjs.org/ja/guide/lint/


