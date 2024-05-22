# Go 1.22におけるforループ意味論

Go 1.22ではfor文の挙動が変化し、反復毎に変数の値がインスタンス化されるようになった。

例えば以下のようなプログラム(`main.go`)を書いたとする。

```
package main

func main() {
	c, out := make(chan int), make(chan int)

	m := map[int]int{1: 2, 3: 4}
	for i, v := range m {
		go func() {
			<-c
			out <- i + v
		}()
	}

	close(c)

	println(<-out + <-out)
}
```

これを go 1.22 で実行すると、for文の挙動は`(1+2) + (3+4)`となり`10`が出力される。  
一方 go 1.22以前（ここではgo 1.21）を用いると、for文で用いられる変数i,vはすべてのループで共通のものが利用されるため、
i,vの最終値が3,4であることから`(3+4) + (3+4)`となり`14`が出力される。

for文は[For statements](https://go.dev/ref/spec#For_statements)にあるとおり下記3種の書き方ができるため、
これら全てに同様の影響がある。

* `for a < b {...}`
* `for ... range {...}`
* `for ...; ...; ...; {...}`

## go 1.22以前でgo 1.22と同様の挙動にするには

変数を共有しないようにするために、forループ内で別変数への割当をすればよい。

```
package main

func main() {
	c, out := make(chan int), make(chan int)

	m := map[int]int{1: 2, 3: 4}
	for i, v := range m {
		i, v := i, v // Hack!
		go func() {
			<-c
			out <- i + v
		}()
	}

	close(c)

	println(<-out + <-out)
}
```

## 1.22の変更はどのような影響があるか

* ループ毎に変数に値が割り当てられるため、遅延評価が必要でかつforループ全体にかかる変数の扱いには気をつけること
  * 例えば、https://go.dev/play/p/lmb2AdjbRgy のようなコードの場合、counterは常に0となってしまう
* クロージャでループ変数を参照する際に、ループ毎に変数が割り当てられることに留意すること
  * 例えば、https://go.dev/play/p/YLaHw--gwzG のようにprintN呼び出し時のループ変数がgo 1.22と以前では異なる
* ループ変数を同時に参照する場合、データ競合などが発見しづらくなる場合がある
  * 例えば、https://go.dev/play/p/Nn8Bbt8Ikar のようにループ変数を`i++`で参照する場合、mainのgoroutineがiを読み取る一方で、for文内のgoroutineがiを変更するため`go vet -race main.go`を実行するとデータ競合が発生していることがわかる

# 参考

* [for Loop Semantic Changes in Go 1.22: Be Aware of the Impact](https://go101.org/blog/2024-03-01-for-loop-semantic-changes-in-go-1.22.html)
* [For statements](https://go.dev/ref/spec#For_statements)
* [Go1.22のfor文と変数スコープ](https://rukiadia.hatenablog.jp/entry/2024/05/10/001632)
