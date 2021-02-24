# GKE Ingress へのアクセス元IPアドレス制限をする方法

GKE Ingress でサービスを公開する際、特定のアクセス元のみ許可する方法を示す。

ここでは、例としてGKE上にkeycloakをデプロイし、
keycloakへのアクセスを１つのグローバルIPアドレスに制限する方法を示す。

[Cloud ArmorでGKE IngressへのアクセスをIPで制御する](https://qiita.com/irotoris/items/8d6be7b0afd9b8afc321)が大いに参考になった。

## 実施内容

* Cloud Armorにて、Ingressへのセキュリティポリシー（アクセスルール）を設定
* Ingressに割り当てる静的IPアドレスの取得
* k8sへDeployment、Service(Type: NodePort)をデプロイ
* k8sへBackend-configをデプロイ
* k8sへIngressをデプロイ

## 詳細

GCPのコンソールを開き、CloudShellを起動する。

※もちろん、手元のマシンからgcloudコマンドでアクセス可能な場合は、それを利用してもよい。

本稿では、作業用ディレクトリ `keycloak-example` で作業を行うこととする。

```
mkdir keycloak-example
```

### セキュリティポリシー（アクセスルール）の作成

[サンプルを作成する](https://cloud.google.com/armor/docs/configure-security-policies?hl=ja#create-example-policies)を参考に、
Cloud Armorにてセキュリティポリシーを作成する。

ここでは、`ingress-ip-whitelist` というセキュリティポリシーを作成する。

```
gcloud compute security-policies create ingress-ip-whitelist --description "sample"
```

その後、（前述の公式ドキュメントの通りであるが）、デフォルトのルールを更新し特定のIPアドレス以外からのアクセスを拒否する。

ここでは、例として `deny-403` としているが必要に応じて `deny-404` などを検討する。

```
gcloud compute security-policies rules update 2147483647 \
    --security-policy ingress-ip-whitelist \
    --action "deny-403"
```

次に、許可したいIPアドレスを受け入れるためのルールを設定する。

ここでは、プライベートIPアドレスを指定しているが、もちろんグローバルIPアドレスでOK。

```
gcloud compute security-policies rules create 1000 \
    --security-policy ingress-ip-whitelist \
    --description "allow traffic from 192.168.1.100/32" \
    --src-ip-ranges "192.168.1.100/32" \
    --action "allow"
```

上記の設定内容については、GCPのコンソールからも確認できる。

### Ingress割り当て用の静的IPアドレスの取得

Ingressに静的IPアドレスを割り当てるため、[新しい静的外部 IP アドレスの予約](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?hl=ja)を参考に以下のコマンドを実行し、静的IPアドレスを取得する。

```
gcloud compute addresses create sample-app-endpoint --global
```

以下のコマンドを実行し、取得した静的IPアドレスを確認する。

```
gcloud compute addresses list

NAME                 ADDRESS/RANGE   TYPE      PURPOSE  NETWORK  REGION  SUBNET  STATUS
sample-app-endpoint  XX.XXX.XXX.XXX  EXTERNAL                                    IN_USE
```

### k8sへDeployment、Service(Type: NodePort)をデプロイ

以下のmanifestを利用し、keycloakアプリケーションをデプロイする。

manifestは、以下の内容となっている。

* namespace: keycloak の作成
* keycloak service の作成
* keycloak deployment の作成

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
        image: quay.io/keycloak/keycloak:12.0.2
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

留意するべき点として以下のことがあげられる。

* service は NodePort で宣言する
* service は 80ポートで待ち受ける（Podは8080ポートで待ち受ける）
* service 及び deployment の matchLabels は同一のもの（ここではkeycloak）を利用する
* deployment の templateセクションにある、metadataは 上記と同じもの（ここではkeycloak）を利用する
* deployment の env にて、keycloakへのログインユーザ及びパスワード（ユーザはadmin、パスワードはadmin）を宣言する
* deployment の待ち受けるポートはHTTPであれば8080、HTTPSであれば8443を宣言する

アノテーション `beta.cloud.google.com/backend-config: '{"ports": {"80":"default-backend-config"}}'` については後述する。

CloudShellまたはgcloudコマンドが利用可能なマシンにて、以下のコマンドを実行し、k8sへデプロイする。

```
kubectl apply -f keycloak.yaml
```

### k8sへBackend-configをデプロイ

GKEにおいてBackendConfigとは、Serviceリソースが `cloud.google.com/backend-config` アノテーションを参照し、
指定されたBackendConfigリソースから設定情報を読み込むことができる仕組みである。

本稿では、BackendConfigにて、上記で設定したセキュリティポリシーを適用する旨を宣言する。

セキュリティポリシーを適用するためのmanifestは以下の通り。

```
apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  namespace: keycloak
  name: default-backend-config
spec:
  securityPolicy:
    name: "ingress-ip-whitelist"
```

CloudShellまたはgcloudコマンドが利用可能なマシンにて、以下のコマンドを実行し、k8sへデプロイする。

```
kubectl apply -f backend-config.yaml
```

BackendConfigに関する詳細な設定は[BackendConfig の Ingress への関連付け](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features?hl=ja#associating_backendconfig_with_your_ingress)を参考にすること。

### k8sへIngressをデプロイ

Ingressが前述で取得した静的IPアドレスを利用するように、manifestを作成する。

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: keycloak
  name: keycloak-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: "sample-app-endpoint"
spec:
  backend:
    serviceName: keycloak
    servicePort: 80
```

CloudShellまたはgcloudコマンドが利用可能なマシンにて、以下のコマンドを実行し、k8sへデプロイする。

```
kubectl apply -f keycloak-ingress.yaml
```
# まとめ

* GKEにてアクセス元IPアドレスを制限しつつkeycloakアプリケーションをデプロイした
* アクセス元制限は、Cloud Armorを利用すると楽


* なお、keycloakはHTTPSでの接続を求められるため、HTTPで接続する場合は別途設定が必要（各自調べておくこと）

# 参考
* [Cloud ArmorでGKE IngressへのアクセスをIPで制御する](https://qiita.com/irotoris/items/8d6be7b0afd9b8afc321)
* [サンプルを作成する](https://cloud.google.com/armor/docs/configure-security-policies?hl=ja#create-example-policies)
* [新しい静的外部 IP アドレスの予約](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?hl=ja)
* [BackendConfig の Ingress への関連付け](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features?hl=ja#associating_backendconfig_with_your_ingress)
