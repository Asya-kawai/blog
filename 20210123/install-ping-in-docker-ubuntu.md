# UbuntuなDockerコンテナに pnig コマンドをインストールする方法

Dockerコンテナに接続。

```
exec -it a628b902909b bash
```

次にコンテナ内で、パッケージリスト更新及び `ping` 関連のパッケージをダウンロード。

```
root@local-control-plane:/# apt update
Get:1 http://security.ubuntu.com/ubuntu groovy-security InRelease [110 kB]
Get:2 http://archive.ubuntu.com/ubuntu groovy InRelease [267 kB]
Get:3 http://security.ubuntu.com/ubuntu groovy-security/multiverse amd64 Packages [1258 B]
Get:4 http://security.ubuntu.com/ubuntu groovy-security/universe amd64 Packages [55.6 kB]
Get:5 http://security.ubuntu.com/ubuntu groovy-security/restricted amd64 Packages [108 kB]
Get:6 http://security.ubuntu.com/ubuntu groovy-security/main amd64 Packages [217 kB]
Get:7 http://archive.ubuntu.com/ubuntu groovy-updates InRelease [115 kB]
Get:8 http://archive.ubuntu.com/ubuntu groovy-backports InRelease [101 kB]
Get:9 http://archive.ubuntu.com/ubuntu groovy/multiverse amd64 Packages [247 kB]
Get:10 http://archive.ubuntu.com/ubuntu groovy/universe amd64 Packages [16.1 MB]
Get:11 http://archive.ubuntu.com/ubuntu groovy/restricted amd64 Packages [87.5 kB]
Get:12 http://archive.ubuntu.com/ubuntu groovy/main amd64 Packages [1768 kB]
Get:13 http://archive.ubuntu.com/ubuntu groovy-updates/restricted amd64 Packages [138 kB]
Get:14 http://archive.ubuntu.com/ubuntu groovy-updates/multiverse amd64 Packages [7531 B]
Get:15 http://archive.ubuntu.com/ubuntu groovy-updates/universe amd64 Packages [117 kB]
Get:16 http://archive.ubuntu.com/ubuntu groovy-updates/main amd64 Packages [372 kB]
Get:17 http://archive.ubuntu.com/ubuntu groovy-backports/universe amd64 Packages [4200 B]
Fetched 19.9 MB in 5s (4173 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
71 packages can be upgraded. Run 'apt list --upgradable' to see them.

root@local-control-plane:/# apt-get install iputils-ping net-tools
Reading package lists... 10%
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  iputils-ping net-tools
0 upgraded, 2 newly installed, 0 to remove and 71 not upgraded.
Need to get 235 kB of archives.
After this operation, 971 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu groovy/main amd64 iputils-ping amd64 3:20200821-2 [42.2 kB]
Get:2 http://archive.ubuntu.com/ubuntu groovy/main amd64 net-tools amd64 1.60+git20180626.aebd88e-1ubuntu2 [192 kB]
Fetched 235 kB in 2s (154 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package iputils-ping.
(Reading database ... 6467 files and directories currently installed.)
Preparing to unpack .../iputils-ping_3%3a20200821-2_amd64.deb ...
Unpacking iputils-ping (3:20200821-2) ...
Selecting previously unselected package net-tools.
Preparing to unpack .../net-tools_1.60+git20180626.aebd88e-1ubuntu2_amd64.deb ...
Unpacking net-tools (1.60+git20180626.aebd88e-1ubuntu2) ...
Setting up net-tools (1.60+git20180626.aebd88e-1ubuntu2) ...
Setting up iputils-ping (3:20200821-2) ...

root@local-control-plane:/#
```

なお、この背景としては、手元にて [kind](https://kind.sigs.k8s.io/) にて構築したk8sの`ClusterIP` への疎通確認。

やりたかったことは、以下のようなこと（ちゃんとできた）。

```
root@local-control-plane:/# curl 10.96.3.59
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@local-control-plane:/#
```

おしまい。
