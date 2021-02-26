# keycloakでHTTPアクセスを許可する方法

[GKE Ingress へのアクセス元IPアドレス制限をする方法](https://github.com/Asya-kawai/blog/blob/main/20210225/source-ip-limitation-for-gke.md) にて、GKE上にサンプルアプリケーションとしてkeycloakをデプロイした。

keycloakは、HTTPSでのアクセスがデフォルトとなっており、HTTPでアクセスした場合、`HTTPS required` と言われてしまう。

そこで、上記で設定したkeycloakをHTTPアクセス可能となるような設定手順を示す。

## 実施内容

* ベースとなるkeycloakのDockerImageを取得
* 上記イメージからコンテナを生成し、コンテナにてHTTPアクセスを許可するよう設定
* 上記コンテナからイメージを作成し、コンテナレジストリにPush
* コンテナレジストリにPushしたイメージを取得するようmanifestを修正
* k8sへDeploymentをデプロイ

## 詳細

GCPのコンソールを開き、CloudShellを起動する。

※もちろん、手元のマシンからgcloudコマンドでアクセス可能な場合は、それを利用してもよい。

本稿では、作業用ディレクトリ `keycloak-example` で作業を行うこととする。
なお、これは[GKE Ingress へのアクセス元IPアドレス制限をする方法](https://github.com/Asya-kawai/blog/blob/main/20210225/source-ip-limitation-for-gke.md) で作成済みのため、後述するyamlファイルの一部はこのURLを参照すること。

```
cd keycloak-example
```

## ベースとなるkeycloakのDockerImageを取得

本稿で利用するkeycloakのイメージは、quay.ioというコンテナレジストリのものを利用する。

以下のコマンドを実行して、イメージを取得する。

```
docker pull quay.io/keycloak/keycloak
```

以下のコマンドを実行して、イメージの確認を行う。

```
docker images
REPOSITORY                  TAG       IMAGE ID       CREATED      SIZE
quay.io/keycloak/keycloak   latest    c069203d2a29   9 days ago   692MB
```

### HTTPアクセスを許可するよう設定

以下のコマンドを実行し、取得したイメージからコンテナを起動する。

```
docker run -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin --name keycloak quay.io/keycloak/keycloak
```

各種オプションの意味は以下の通り。

* `-e KEYCLOAK_USER=admin`: adminという名称のユーザを設定
* `-e KEYCLOAK_PASSWORD=admin`: adminユーザに対するパスワードを`admin`として設定
* `--name keycloak`: keycloakという名称でコンテナを起動

なお、`-d` オプションでバックグラウンドで起動しても良いが、ログを見たかったので`-d`は利用していない。

次に別のターミナルを開いて以下のコマンドを実行し、コンテナに接続する。

```
docker exec -it keycloak bash
```
コンテナ内で以下のコマンドを実行し、HTTPアクセスが可能となるよう設定を変更する。

```
/opt/jboss/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin
```

上記のコマンド実行後、adminユーザのパスワードが求められるため、
コンテナ起動時に指定したパスワード（ここでは`admin`）を入力する。

```
/opt/jboss/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE
```

最後に `exit` を入力し、コンテナから切断する。

### コンテナレジストリにPush

下記コマンドを実行し、終了したコンテナIDを確認する。

```
docker ps -a
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS                     PORTS     NAMES
08e40dcae3fd   quay.io/keycloak/keycloak   "/opt/jboss/tools/do…"   37 seconds ago   Exited (0) 3 seconds ago             keycloak
```

上記から container ID が `08e40dcae3fd` であることがわかるので、
以下のコマンドを実行しHTTPアクセス許可を施したイメージとして保存する。

```
docker commit 08e40dcae3fd keycloak:latest

docker images
REPOSITORY                  TAG       IMAGE ID       CREATED         SIZE
keycloak                    latest    08463b433ffd   3 seconds ago   693MB
quay.io/keycloak/keycloak   latest    c069203d2a29   9 days ago      692MB
```

上記で作成したイメージにGCRへPushするためのタグを付与する。

```
docker tag keycloak gcr.io/<プロジェクトID>/keycloak
```

プロジェクトIDは、GCPのプロジェクトIDを示す。

以下のコマンドを実行しGCRへPushする。

```
docker push gcr.io/<プロジェクトID>/keycloak
```

以下のコマンドを実行し、GCRにアップロードされたイメージを確認する。

```
gcloud container images list-tags gcr.io/<プロジェクトID>/keycloak
DIGEST        TAGS    TIMESTAMP
c0bb98e6e9b5  latest  2021-02-26T01:27:53
```

### コンテナレジストリにPushしたイメージを取得するようmanifestを修正

前回利用した、`keycloak.yaml`を以下のように、GCRのイメージを利用するように修正する。

```
kind: Namespace
apiVersion: v1
metadata:
  name: keycloak
  labels:
    name: keycloak
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
  annotations:
    beta.cloud.google.com/backend-config: '{"ports": {"80":"default-backend-config"}}'
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
  selector:
    app: keycloak
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: gcr.io/<プロジェクトID>/keycloak:latest
        env:
        - name: KEYCLOAK_USER
          value: "admin"
        - name: KEYCLOAK_PASSWORD
          value: "admin"
        - name: PROXY_ADDRESS_FORWARDING
          value: "true"
        ports:
        - name: http
          containerPort: 8080
        - name: https
          containerPort: 8443
        readinessProbe:
          httpGet:
            path: /auth/realms/master
            port: 8080
```

前回との差分は以下のようになる。

```
<         image: quay.io/keycloak/keycloak:12.0.2
---
>         image: gcr.io/<プロジェクトID>/keycloak:latest
```

以下のコマンドを実行し、k8sへデプロイする。

```
kubectl apply -f keycloak.yaml
```

以上を行うことで、Ingressに設定したグローバルIPアドレス経由で且つHTTPでkeycloakにアクセスできる。

# 参考
* ["HTTPS required" while logging in to Keycloak as admin](https://stackoverflow.com/questions/30622599/https-required-while-logging-in-to-keycloak-as-admin)
* [イメージのpushとpull](https://cloud.google.com/container-registry/docs/pushing-and-pulling?hl=ja)
