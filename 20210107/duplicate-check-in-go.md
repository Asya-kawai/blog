# Go言語で重複をチェックする

Goには、Slice内の要素を重複チェックするための便利な関数がない。

そこで、以下のように自分でサクッと書く必要がある。

やり方は色々だが、ここでは2通り示す。

## Sliceから要素を1つずつ取り出してチェックする方法

```
// idDup は slice を受け取って重複した要素があれば true, なければ false を返す関数。
func isDup(s []int) bool {

	tmp := []int{}
	for _, e := range s {
		for _, e2 := range tmp {
			if e == e2 {
				return true
			}
		}
		// 重複していない要素はtmpに保存
		tmp = append(tmp, e)
	}
	// 重複がなければ、 false を返す
	return false
}
```

使い方は以下の通り。

```
func main() {
	fmt.Println("Hello, playground")
	list := []int{1, 2, 3, 4, 5, 5, 6, 7, 8, 9, 10}

	if isDup(list) {
		fmt.Printf("要素が重複しています\n")
	}
}
```

## Mapで要素をチェックする方法

```
func isDup(s []int) bool {
	// Mapをｓ生成
	tmp := make(map[int]int)
	for _, e := range s {
		// キーと一致する要素があれば、true を返す
		if _, ok := tmp[e]; ok {
			return true
		}
		// なければ、mapに追加
		tmp[e] = e
	}
	// 重複がなければ、 false を返す
	return false
}
```

使い方は、sliceの場合と同じ。
