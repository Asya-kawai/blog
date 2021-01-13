# pingのcapabilityを設定する in Ubuntu

Dockerコンテナから `/bin` をコピーした後で気づいたが、
一般ユーザにて `ping` の実行を実行したところ、
以下のようなメッセージがでるようになってしまった。

```
ping: socket: Operation not permitted
```

これは、`Capability` という権限グループ（ここではping用のCapability）
に所属していないため、発生している。

そこで、以下のようなコマンドを実行し、
一般ユーザでも `ping` が実行できるように設定する。

まずは、現在の `ping` のCapabilityを確認する。

```
getcap /bin/ping
```

今は存在していないため、`cap_net_raw+ep` というCapabilityに追加する。

```
sudo setcap 'cap_net_raw+ep' /bin/ping
/bin/ping = cap_net_raw+ep
```

一般ユーザにて、 `ping` が実行できることを確認する。

```
ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=1.98 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.988/1.988/1.988/0.000 ms
```

なお、Ubuntu 20.04 では `cap_net_raw` がなくても動作するらしい。

[ping を実行するのに CAP_NET_RAW は必要なくなっていた
](https://blog.ssrf.in/post/ping-does-not-require-cap-net-raw-capability/)

Capability について詳しく知りたい方は、`man 7 capabilities` を打つか、
[Capabilities](https://linuxjm.osdn.jp/html/LDP_man-pages/man7/capabilities.7.html)
を参照されたい。

# 参考

* [Capabilities](https://linuxjm.osdn.jp/html/LDP_man-pages/man7/capabilities.7.html)
* [ping を実行するのに CAP_NET_RAW は必要なくなっていた
](https://blog.ssrf.in/post/ping-does-not-require-cap-net-raw-capability/)
