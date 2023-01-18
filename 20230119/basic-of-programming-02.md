# プログラミングの基礎理論 第2回 言語の機能的な定義

Twitterにて[このようなツイート](https://twitter.com/AtsushiOhori/status/1614999135559757824?s=20&t=izl1aiC2jkmvU4B-4QFEew)を見かけたので、内容を確認してみた。

これまでインターネットや書籍で軽く触れられてきた内容に切り込んでいくものだったので、理解を深めることができた。

その内容をまとめていく。

## 概要

言語は文法で定義される。

例えば、MLの一部の式は以下のように定義される。

```
<exp> ::= <id>                     // 変数
      |   <n> | <S> | true | false // 自然数(n), 文字列(S) その他定数
      |   fn <id> => <exp>         // 関数式
      |   <exp> <exp>              // 関数適用
      |   ...
```

プログラミング言語の理論ではより抽象的な定義を行うため、変数や定数を「与えられた集合」とし、これを代表するものを`メタ変数`と呼ぶ。

ラムダ式では以下の集合とメタ変数を導入する。

* 集合(Var)に対するメタ変数を`x`とする
* 定数(Const)に対するメタ変数を`c^b`(c of b)とする
  * ※ b はint等の型を明示するためのもの

構文自体に対してもメタ変数を導入できる。

* ラムダ式の集合(lambda)に対するメタ変数を`e`とする
  * ML式における非終端記号`<exp>`に相当する

BNF記法では以下のように表される。

```
e ::= x | c^b | (lambda x.e) | (e e)
```

これはMLの一部の式に示した定義と同等であることが分かる。  
このような定義を抽象構文(abstract syntax)の定義と呼ぶ。  
ここで抽象とは、語彙解析や構文解析の詳細について了解されていることを示す。

なぜ抽象構文を用いるか。  
言語の型等の性質の理論的な分析を行うため、と言える。  
また分析の対象となるのは、機能法等で分析可能な集合である、と言える。


ここで以下のBNFを思い出そう。

```
e ::= x | c^b | (lambda x.e) | (e e)
```

上記eはラムダ式の集合とみなせる。この集合を&Lambda;とする。

するとラムダ式の集合e（または&Lambda;と表現）の条件が見えてくる。

* &Lambda;はxが代表する集合Varを含む
* &Lambda;はcが代表する集合Constを含む
* もし&Lambda;にeが含まれるのであれば、eを使った式も&Lambda;に含まれる
* もしe<sub>1</sub>及びe<sub>2</sub>が&Lambda;に含まれるのであれば、(e1, e2)も&Lambda;に含まれる
* &Lambda;は以上の要素のみを含む

またBNFから、&Lambda;を生成する以下の規則も見えてくる。  
つまり先程のBNFは、&Lambda;の要素を生成する以下の操作であると言える。

* xと書いた場合、xが代表する集合Varを&Lambda;の要素に加える操作である
* c^bと書いた場合、c^bが代表する集合Constを&Lambda;の要素に加える操作である
* もしeが集合lambdaに含まれるなら、(lambda x.e)と書いた場合、これを&Lambda;に加える操作である
* もしe<sub>1</sub>,e<sub>2</sub>が集合lambdaに含まれるなら、(e<sub>1</sub> e<sub>2</sub>)と書いた場合、これを&Lambda;に加える操作である

また以上のことから、ラムダ式の集合は以上の要素生成を（無限に）繰り返して得られる集合であると言える。

## 集合の帰納的定義

動画では[ここから](https://youtu.be/RlSZVXW-2oA?t=1959)スタートする内容である。

さて、前述したラムダ式の集合における条件や規則について、それらが数学的に定義可能かを見ていく。

まず、数学的定義を行うために必要な道具（集合に関する記法）を整理する。

* A,A<sub>1</sub>...,A<sub>n</sub> を集合とする
* 集合に対して以下の集合演算が可能である
  * A<sub>1</sub> &otimes; ...A<sub>x</sub> = {(a<sub>1</sub>,...,a<sub>n</sub>) | a<sub>i</sub> &isin; A<sub>i</sub> (1 &le; i &le; n)}
    * これはA<sub>1</sub>,...A<sub>n</sub>の直積を表す
  * A<sup>n</sup> = A &otimes; ... &otimes; A
    * これは集合Aのn次の直積を表す
* 関数を代表するメタ変数fに対して、その定義域を dom(f) と表記する
* Xがdom(f)の部分集合である時（すなわちX &sube; dom(f)の時）、集合{f(x) | x &isin; X}をf(X) と表記する
* fのXへの制限すなわち定義域をXに制限した集合{(a, b) | (a, b) &isin; f, a &isin; X}で表される関数を、f|<sub>x</sub>と表記する
* f|<sub>dom(f)\{x}</sub>すなわちXへの制限を取り除いたものをf|&not;xと表記する
* 変数x<sub>1</sub>〜x<sub>n</sub>と対応する値v<sub>1</sub>〜v<sub>n</sub> (x<sub>i</sub> &ne; x<sub>j</sub>, 1 &le; i &le; j &le; n)に対して、f{x<sub>1</sub>:v<sub>1</sub>,...,x<sub>n</sub>:v<sub>n</sub>}は新たな関数f'を表す
  * f'の定義域dom(f')について、dom(f') = dom(f) &cup; {x<sub>1</sub>,...,x<sub>n</sub>} となり
  * 且つf'の値について、f'(y) = f(y) (y &ne; x<sub>i</sub>, 1 &le; i &le; n) または v<sub>i</sub> (y = x<sub>i</sub>)となる
    * x<sub>i</sub>はdom(f)の定義であっても良い、そうでなければv<sub>i</sub>となるという意味

次に、全体集合Uを置き、集合Fを f &isin; U<sup>n</sup> &rarr; U つまり、Uのn次の直積からUへの関数の集合と定義する。

この時nをfのランクと言いrank(f)と書く。
また、ランクがnであるFの要素をf<sup>r(n)</sup>と書く。

ここで、Uに対する部分集合X（X &sube; U）に対して、{f<sup>r(n)</sup> (x<sub>1</sub>,...,x<sub>n</sub>) | x<sub>i</sub> &isin; X, f<sup>r(n)</sup> &isin; F} となる集合をF(X)と書く。  
つまりF(X)は、関数集合Fに属するfについて、ランクnにx<sub>1</sub>〜x<sub>n</sub>（xはXの要素）を与えfに適用した結果を集めた集合である。  
さらにF(X) &sube; X の時、すなわちXの要素(x<sub>i</sub>等)をfに適用した際にその結果がXの範囲に留まる時、「XはFに関して閉じている(Closed under F)」と言う。

## 帰納的閉包

部分集合C（C &sube; U）を与えられた集合とし、CのFに関する帰納的閉包を「集合Cを含みFに関して閉じている集合の最小のもの」と定義する。またこれを Ind(C, F)と書くことにする。

ここで最小とは、集合の包含関係（例えば A &sube; B）に関して最小のもの、という意味である。

この講義で言いたいことは「BNFを含む再帰的な規則で定義される集合は、帰納的閉包である（帰納的閉包で表される）」ということである。


*帰納的閉包の性質1*

そもそもInd(C, F)つまり集合Cを含み関数集合Fに関して閉じている最小の集合というものは存在するのだろうか（直感的には存在するとは思うが、確認することが大事だ）。

そこでXを 空でない集合の集まり（集合）とし、以下の演算を定義する。

&cap; X = {a | Xの要素（実体は集合）である全てのY（&forall;Y &isin; X）について a &isin; Y}

つまり上記の演算は、Xの全ての部分集合における共通集合を得ることになるため、必然的に最小の集合を得る演算となっている。

さて、Uの部分集合C（C &sube; U）且つ F(U) &sube; U から、U自身はCを含み且つFに関して閉じた集合全体の集合はUの要素を含み空ではないことが分かる。  
また、空ではない集合の集合Xについて &cap; X の演算を定義したことから、F(X)すなわちXがFに関して閉じている場合、&cap; X においてもFに関して閉じていると言える。

したがって Ind(C, F)は確かに存在し以下のように定義できる。

Ind(C, F) = &cap;{V | V &sube; U, C &sube; V, F(V) &sube; V}

つまり Uの部分集合V（V &sube; U）は、Uの部分集合Cが含まれ且つFに関して閉じている全てのものの集まりであり、これに対して &cap; をとったものである。&cap; をとるというのは、Vにおける最小の集合を得ることであり、ここではCが最小の集合であるため、Ind(C, F)は確かに存在することが分かる。


*帰納的閉包の性質2*

ここでは、Ind(C, F)にどのような要素が含まれているかを確かめていく。

自然数で添字付けられた無限列（集合系列） {X<sub>n</sub> | n = 0,1,...,n} を以下のとおり定義する。

X<sub>0</sub> = C
X<sub>i+1</sub> = X<sub>i</sub> &cup; F(X) (0 &le; i)

上記のX<sub>0</sub>は定数Cを表す。
X<sub>i+1</sub>は、1つ前の値であるX<sub>i</sub>とF(X<sub>i</sub>)（つまり関数集合Fに属するfにX<sub>i</sub>を適用して得られる全ての値）の和集合を表す。
つまり、上記の漸化式で表される集合系列は、添字の数を大きくなる毎にその集合自体も大きくなる。

この集合系列のもとで、Ind(C, F)は以下のように定義できる。

Ind(C, F) = &cup; {X<sub>i</sub> | 0 &le; i}

（それはそうか、という感じもするが、証明が必要だ）

*性質2の証明*

性質2を証明するにはどのようにすれば良いか。以下の2つを証明すれば良い。

1. Ind(C, F) &sube; &cup; {X<sub>i</sub> | 0 &le; i}
2. &cup; {X<sub>i</sub> | 0 &le; i} &sube; Ind(C, F)

1.については、次のステップで証明できる。

1. &cup; {X<sub>i</sub> | 0 &le; i}がFに閉じていることを示す
2. f<sup>r(n)</sup>をFの任意の要素とし、&cup; {X<sub>i</sub> | 0 &le; i}<sup>n<sup> （n次の直積）の任意の要素（
実際はX<sub>i</sub>で表される要素の組）をxとする
3. そのようなxをとった時、あるkが存在して x &isin; (X<sub>k</sub>)<sup>n</sup>であることを示す
4. するとf<sup>r(n)</sup> &isin; X<sub>k+1</sub> &sube; &cup; {X<sub>i</sub> | 0 &le; i}である
5. 同様にF(&cup; {X<sub>i</sub> | 0 &le; i}) &sube; &cup; {X<sub>i</sub> | 0 &le; i}である
6. よってInd(C, F) &sube; &cup; {X<sub>i</sub> | 0 &le; i}である

※ 2,3のステップが微妙に整理できていないかも？


2.については、次のステップで説明できる。

1. 定義よりX<sub>0</sub> = C &sube; Ind(C, F)である
2. X<sub>i</sub> &sube; Ind(C, F)と仮定する
3. Ind(C, F)はFに閉じているのだから、F(X<sub>i</sub>) &sube; Ind(C, F)である
4. 定義よりX<sub>i+1</sub> = X<sub>i</sub> &cup; F(X<sub>i</sub>)であるから、X<sub>i+1</sub> &sube; Ind(C, F)である
5. よって&cup; {X<sub>i</sub> | 0 &le; i} &sube; Ind(C, F)である

## 帰納的閉包によるラムダ式の理解

この講義で言いたいことは「BNFを含む再帰的な規則で定義される集合は、帰納的閉包である（帰納的閉包で表される）」ということであった。早速見ていこう。

全体集合U（例えば構文木全体からなる集合等）を置き、ラムダ式の集合&Lambda;を帰納的閉包として定義する。
なおこの時&Lambda;は全体集合Uの部分集合になっている、

さて集合Varに対するメタ変数x（x &isin; Var）について、e（ラムダ式の集合&Lambda;に対するメタ変数）から (lambda x.e)を作る関数をf<sup>1</sup><sub>lambda x</sub>、e<sub>1</sub>及びe<sub>2</sub>から(e<sub>1</sub> e<sub>2</sub>)を作る関数をf<sup>2</sup><sub>app</sub>とすると、関数集合Fは以下のように定義できる。

F<sub>&Lambda;<sub> = {f<sup>1</sup><sub>lambda x</sub> | x &isin; Var} &cup; {f<sup>2</sup><sub>app</sub>}

するとラムダ式の集合&Lambda;は、以下のとおり定義できる。

&Lambda; = Ind(Var &cup; Const, F<sub>&Lambda;<sub>)

つまりX<sub>0</sub>に相当するVar及びConstの和集合から始まり、それらを用いて作成できる関数を要素に持つ集合Fに関して閉じている最小の集合を示している。

## BNFを帰納的閉包の文脈で見直してみる

&Lambda; = Ind(Var &cup; Const, F<sub>&Lambda;</sub>) = &cap; {V | V &sube; U, (Var &cup; Const) &sube; V, F<sub>&Lambda;</sub>(V) &sube; V}

と考えると、&Lambda;は次の制約を満たすものであると定義できる。

* (Var &cup; Const) &sube; V より&Lambda;は集合Varと集合Constを含む = (Var &cup; Const) &sube; &Lambda;
* F<sub>&Lambda;</sub>(V) &sube; V よりF<sub>&Lambda;</sub>(&Lambda;) &sube; &Lambda;つまりf<sup>1</sup><sub>lambda x</sub>及びf<sup>2</sup><sub>app</sub>に関して閉じた集合である
* 上記を満たす最小の集合である

つまり、

* &Lambda;はxが代表する集合Varを含む = Var &sube; &Lambda; である
* &Lambda;はcが代表する集合Constを含む = Const &sube; &Lambda; である
* もし&Lambda;にeが含まれるのであれば、eを使った式も&Lambda;に含まれる = もし e &sube; &Lambda; ならば (lambda x.e) &sube; &Lambda; である
* もしe<sub>1</sub>及びe<sub>2</sub>が&Lambda;に含まれるのであれば、(e<sub>1</sub> e<sub>2</sub>)も&Lambda;に含まれる = もしe<sub>1</sub> &sube; &Lambda; 且つ e<sub>2</sub> &sube; &Lambda; ならば (e<sub>1</sub> e<sub>2</sub>) &sube; &Lambda; である
* &Lambda;は以上の要素のみを含む ← これがはっきりとした！

と言える。

同様に&Lambda;の要素を生成する操作という文脈においても別の見方ができる。

&Lambda; = Ind(Var &cup; Const, F<sub>&Lambda;</sub>) = &cup; {X<sub>i</sub> | 0 &le; i}

* (Var &cup; Const)の要素を追加する
* 全てのx, y &sube; &Lambda; に対して、f<sup>1</sup><sub>lambda x</sub>及びf<sup>2</sup><sub>app</sub>を追加する

つまり

* xと書いた場合、xが代表する集合Varを&Lambda;の要素に加える操作である
* c^bと書いた場合、c^bが代表する集合Constを&Lambda;の要素に加える操作である
* もしeが集合lambdaに含まれるなら、(lambda x.e)と書いた場合、これを&Lambda;に加える操作である
* もしe<sub>1</sub>,e<sub>2</sub>が集合lambdaに含まれるなら、(e<sub>1</sub> e<sub>2</sub>)と書いた場合、これを&Lambda;に加える操作である
* &Lambda;は異常の要素の生成を（無限に）繰り返して得られる集合である ← これがはっきりした！

と言える。

# 参考

* [「型推論」特別講義 第２回 （プログラミング言語の基礎理論シリーズ）](https://youtu.be/RlSZVXW-2oA)
