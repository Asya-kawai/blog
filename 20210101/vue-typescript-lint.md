# vue + tyepscript な lintの設定

まずはここをみる。

* https://qiita.com/TomoShiozawa/items/89d96da281b033dcccc6


これで、ts にも対応できるらしい

* https://tech-1natsu.hatenablog.com/entry/2019/02/10/234421


これもやってみた

* https://qiita.com/suzuki_sh/items/fe9b60c4f9e1dbc5d903

いろいろやって、こんな感じにしたけどうまくいかず・・・

```
module.exports = {
  root: true,
  env: {
    browser: true,
    node: true
  },
  parser: '@typescript-eslint/parser',
  //parserOptions: {
  //  parser: 'babel-eslint'
  //},
  extends: [
    'eslint:recommended',
    'plugin:vue/recommended',
    'plugin:nuxt/recommended',
    'plugin:prettier/recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/eslint-recommended',
    '@nuxtjs/eslint-config-typescript',
  ],
  // required to lint *.vue files
  plugins: [
    'vue',
    'prettier',
    '@typescript-eslint'
  ],
  // add your custom rules here
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'vue/html-closing-bracket-newline': 'off',
    "vue/max-attributes-per-line": [
      "error",
      {
        "singleline": 5,
        "multiline": {
          "max": 1,
          "allowFirstLine": false
        }
      }
    ]
  }
}
```

この時のエラーは、以下の通り。

```
eslint --ext .js,.vue --ignore-path .gitignore pages/login.vue

Oops! Something went wrong! :(

ESLint: 7.16.0

Error: Failed to load plugin '@typescript-eslint' declared in '.eslintrc.js': Cannot find module 'eslint/lib/rules/utils/ast-utils'
...
```

というわけで、nuxtjsでトライ・・・が、ダメ。

* https://qiita.com/INOUEMASA/items/c60515854dd255d1178d



7日前に同様の問題が発生した旨が・・・

* https://github.com/webpack-contrib/eslint-loader/issues/287


これによるとnodeのバージョンを上げたら解決したらしい。

nodeのバージョンを 15.5.0 にした。


eslintはグローバルにインストールせずに使う。パスが node_modules以下になるので注意

* https://qiita.com/mysticatea/items/6bd56ff691d3a1577321

つか、公式に従ってやればよかったんじゃね

* https://typescript.nuxtjs.org/guide/lint/


ごちゃごちゃしたら動いた

* https://twitter.com/asya_aoi1049/status/1345043952714465282?s=20


