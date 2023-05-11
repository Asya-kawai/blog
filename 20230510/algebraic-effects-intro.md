# Algebraic Effects入門

きっかけはOCamlでHTTP Clientを実装した際に[ocaml-cohttp](https://github.com/mirage/ocaml-cohttp)を参考に見つけたIOモナドだった。

https://github.com/mirage/ocaml-cohttp/blob/master/cohttp/src/s.ml

モナド（monad）は簡単にいうと「副作用を扱う」ための手法である。  
副作用とは入出力、破壊的代入、例外処理といった「主たる計算（作用）以外の、何らかの状態を変化させる作用」を指す。

Haskellにおいてモナドはプリミティブなものであるが、OCamlにおいてはそうではない。

しかし、同じ関数型言語に分類されるOCamlにもモナドを期待・実装する人たちが一定数いる。  
OCamlにおけるモナド（特にIOモナド）はどれほど有用なのかを調べる中で次のような議論を見つけた。

> OCamlでIOモナドを実装するための取り組みはあるか？OCamlにはモナド実装のための議論が驚くほど少ない。
> OCamlはHaskellでないことは理解しているが、Haskellと同様にEffectベースのプログラミングはOCamlでも有用だと思っている。どうだろう？

引用： https://discuss.ocaml.org/t/io-monad-for-ocaml/4618

これに対する回答として興味深いものをピックアップし要約すると

> Haskellは非常に弱い意味論しか持たず、実行順序や実行自体（例えば値の評価等）を保証しないため、データの依存関係を維持し計算を任意の順序で組み立てるための仕組みとしてIOモナドを言語機能として提供している。
> 一方OCamlでは強力なセマンティクスを備えており、評価の順序を正確に定義し、計算に副作用を持たせず、監視可能な方法で計算の順序が変更されないことを保証しているため、IOモナドが必要ない。

というものがあった。

以下はより詳細な回答を示したものである。  
長いので急ぐ人は読み飛ばしてもらいたい。

> HaskellにおいてIOモナドは、Haskellの美しい純粋な数学的意味論と、醜い現実世界との間にできた副産物だ。
> つまりモナドは現実世界の酷さを隠してくれる。
> そもそもHaskellは非常に弱い意味論しか持たず、実行順序や実行自体（例えば値の評価等）を保証しない。
> データの依存関係を維持するために、計算を任意の順序で組み立てる自由を保留（意訳：奪う）する。
> これは言語実装者にとって自由度が高いが、一方で言語利用者は一種の制限を加えていることになる。
> そしてIOモナドの存在自体がこれを示している。
>
> 言語実装者は「どのような順番で呼び出すか」を制御する機能を言語利用者に提供する必要があり、これがIOモナドが存在する理由である。
> IOモナドは、計算に順序を課す唯一の方法である。
>
> 一方OCamlは強力なセマンティクスを備えており、評価の順序を正確に定義し、計算に副作用を持たせず、監視可能な方法で計算の順序が変更されないことを保証する。
> これは（Haskellの場合とは異なり）言語実装者から多くを奪い、コンパイラの実装が困難になる一方で、言語利用者に多くの権限（意訳：自由）が与えられる。
> 人々の労力のほとんどは言語開発ではなく言語使用に費やされるため、妥当なトレードオフだと言える。つまりコンパイラは1度作ってしまえば何度も利用されるため、コンパイラに複雑さに投資しても問題ない。
>
> とは言え、強力なセマンティクスによる言語の制限、参照透過性の欠如、モノコア実装、コンパイラによる最適化機会の喪失といった、言語利用者が副作用に対して支払わなければならない代償もある。
> しかし、すでにこの代償を支払っているのであれば、（代償によって得た）上記の保証を受け取らない理由がどこにあるだろうか（意訳：受け取るべきだ）。
>
> OCamlが厳密であり、関数適用の順序が評価の順序を強制することを考えると、IOモナドは単なるサンクとして実装できる。
> `type 'a io = unit -> 'a`
> 純粋な値は以下のようなIOモナドにリフトできる。
>  `let return x = fun () -> x`
> 計算はバインド演算子によってつなげることができる。
> `let (>>=) c1 c2 = fun () -> c2 (c1 ())`
>
> （略）
>
> 最も重要なことは純粋なOCamlを用いてIOモナドを実装できたことだ。
> HaskellではIOモナドを実装することはできない。
> IOモナドは言語プリミティブだ。それも評価の順序、副作用、状態など1つのものに多くの概念が詰め込まれている。
> OCamlでは実装可能であるため、必要なものだけを含む、より優れた抽象化ができる。
> したがってプリミティブなIOモナドは必要ない。モナドが必要なら、必要なことだけを実行するモナドを作るだけだ。

引用： https://discuss.ocaml.org/t/io-monad-for-ocaml/4618/11?u=asya-kawai

さて、上記ディスカッションに「IOモナドに関して、Algebraic Effectsはゲームチェンジャーになりえるか」というコメントもあった。

https://discuss.ocaml.org/t/io-monad-for-ocaml/4618/12?u=asya-kawai

ここで初めてAlgebraic Effectsを見たわけだが、これがどのようなものか知らなかったので調べてみることにした。  
その内容を以下にまとめる。

## イメージで捉えるAlgebraic Effects

Algebraic Effects は学術的なところから始めると非常に分かりづらいため、触りとして[我々向けのAlgebraic Effects入門](https://overreacted.io/ja/Algebraic-Effects-for-the-rest-of-us/)がとても参考になった。

上記の記事ではJavaScriptを例に説明されているが、例外処理を備えた言語であれば同様の考えができる。

```
interface User { 
    name: string;
}

function getName(user:User) {
    const name = user.name;
    if (name === null) {
        throw new Error('A girl has no name!');
    }
    return name;
}

const arya = { name : 'Gendry' };
getName(arya);
console.log(getName(arya)); // OK

const gendry = { name : null };
try {
    getName(gendry);
} catch (err) {
    console.log('Oops, that did not work out: ', err); // Rearched here!
}
```

上記の例は記事の例を書き直したものだが、コードの意図は変えていない。

* getName関数はuserオブジェクトのnameフィールドが`null`の場合、例外を発生させる
* 例外は最寄りの`catch`節に伝播する
* aryaはnameフィールドに文字列があるが、gendryはnameフィールドがnullであるため例外がcatchされる

さて、例外が発生すると例外が発生した箇所に戻ることができない。
一度catch節に来てしまったら、元のコードをそこから再開というわけにはいかない。  
例外とはそういうものだ。

**これを可能にするのがAlgebraic Effectsだ**（ざっくりと解釈すると）。

仮にJavaScriptに Algebraic Effects が実装されたら、以下のように書くことで元のコードに復帰できるだろう。

```
interface User { 
    name: string;
}

function getName(user:User) {
    const name = user.name;
    if (name === null) {
        name = perform 'ask_name'; // performはどんな値も取ることができる
    }
    return name;
}

const gendry = { name : null };
try {
    getName(gendry);
} handle (effect) {
    if (effect === 'ask_name') {
        resume with 'Arya Stark';
    }
}
```

上記の例は、`try / catch`の代わりに`try / handle`を用いていており、
これは「例外を発生させる代わりにエフェクトを発生させる（perform an effect）」している。

performはどんな値でも受け取ることができ、
エンジンはperformを行うとコールスタック上の最も近い`try / handle`を見つけに行く。

```
function getName(user:User) {
    const name = user.name;
    if (name === null) {
        name = perform 'ask_name'; // <-- peformしている箇所
    }
    return name;
}
```

上記の例では、`handle (effect)`によってnameフィールドがnullであった場合の挙動を定義している。

`resume with`によって`Arya Stark`が返され、結果として`name = 'Arya Stark'`が評価され、
getName関数の`return name;`に至る。

```
try {
    getName(gendry);
} handle (effect) {
    if (effect === 'ask_name') {
        resume with 'Arya Stark'; // <-- 'Arya Stark'を返す
    }
}
```

そう、 **エフェクトを引き起こした箇所に戻ることができるのだ！**

## 備考

Algebraic Effectsはうまく副作用を扱う機構であるためモナドと比較され、
しばしば純粋関数型プログラミング特有のものかと思われるかもしれないが、そうではない。

純粋でない関数型プログラミングや、他のパラダイムを持つ言語にとっても「何を」「どうやるか」が明確になるはずだ。

```
interface Dir {
    Name: string;
    // Others... ;
}

function enumerateFiles(dir: Dir) {
    const contents = perform OpenDirectory(dir);        // 何を：ファイルを開く
    perform Log('Enumerating files in ', dir);          // 何を：ログを記録する

    contents.map(file => perform HandleFile(file));     // 何を：ファイルを操作する
    perform Log('Enumerating subdirectories in ', dir); // 何を：ログを記録する

    // We can use recursion or call other functions with effects
    contents.dir.map(directory => enumerateFiles(directory));

    perform Log('Done');                                // 何を：ログを記録する
}

try {
    enumerateFiles('C:\\');
} handle (effect) {
    if (effect instanceof Log) {
        myLoggingLibrary.log(effect.message);                    // どうやって：myLoggingLibrary.log関数を使って
        resume;
    } else if (effect instanceof OpenDirectory) {
        myFileSystemImpl.openDir(effect.dirName, (contents) => { // どうやって：myFileSystemImpl.openDir関数を使って
            resume with contents;
        })
    } else if (effect instanceof HandleFile) {
        files.push(effect.fileName);                             // どうやって：files.push関数を使って
        resume;
    }
}
```

## JavaScriptにおけるAlgebraic Effectsの考察

考察については、[我々向けのAlgebraic Effects入門](https://overreacted.io/ja/Algebraic-Effects-for-the-rest-of-us/)の「関数に色はない」を参照されたい。

# 参考

* [我々向けのAlgebraic Effects入門](https://overreacted.io/ja/algebraic-effects-for-the-rest-of-us/)
* [Algebraic Effects for Functional Programming](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/08/algeff-tr-2016-v2.pdf)
* [モナド](https://en.wikipedia.org/wiki/Monad_(functional_programming))
* [第3章 モナド - Guppy](http://guppy.eng.kagawa-u.ac.jp/2007/HaskellKyoto/Text/Chapter3.pdf)
