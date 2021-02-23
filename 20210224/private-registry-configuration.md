# k3dでプライベートコンテナレジストリを利用する方法

k3dで外部のプライベートコンテナレジストリを利用するには、以下のようなyamlファイルを生成し、
これを `/etc/rancher/k3s/registries.yaml` にマウントする必要がある。

```
mirrors:
  mycustomreg.com:
    endpoint:
      - "https://mycustomreg.com:5000"
```

カレントディレクトリに `registries.yaml` を置いた状態で、以下のコマンドを実行する。

```
k3d cluster create --volume $(pwd)/registries.yaml:/etc/rancher/k3s/registries.yaml local-cluster
```

# 参考
* [Private Registry Configuration](https://rancher.com/docs/k3s/latest/en/installation/private-registry/)

