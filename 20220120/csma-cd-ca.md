# CSMA/CA と CSMA/CD の違い

## CSMA/CA

`CSMA/CA` は無線LANの通信手順として採用される。

`CSMA/CD` と違い、
こちらは伝送媒体である電波（CSMA/CDの場合は有線LAN）に、通信中のホストがいないかを事前に確認してから通信を行う。

事前に通信中のホストがいないかどうかを確認することを `Carrier Sence(CS)`といい、
その後で通信を開始することを`Multiple Access(MA)` という。

また、無線LANではフレームの衝突を検知できないため、
それを回避（`Collision Avoidance`）するしかないため、この方式が無線LANで採用されている。

## CSMA/CD

`CSMA/CD` は有線LANで且つ半二重通信（つまりリピータハブを利用）する場合に採用される。

`CSMA/CD` は
（一応LANケーブルの通信状態を確認し、他ホストがフレームが送信されていないことを確認した上で）
フレームを送信した後でコリジョンが発生した場合は、これを検知（`Collision Detection`）し、
ランダムな時間待ってから再送する。

なお、現在普及しているスイッチングHUBを利用する場合は、全二重通信となるため、CSMA/CDは利用されない。


# 参考
* [Wireless LAN - CSMA/CA](https://www.infraexpert.com/study/wireless6.html)
* [Ethernet LAN - CSMA/CD](https://www.infraexpert.com/study/ethernet5.html)
