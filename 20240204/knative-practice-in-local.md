# Knativeをローカル環境で試す

## kindのインストール

ローカル環境で試す方法の1つにkindがある。  
kindはDockerコンテナを利用してK8sクラスタを構築するツール。

バージョンは https://kind.sigs.k8s.io/docs/user/quick-start/ などで確認すること。

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /path/to/bin/kind
```

`/path/to/bin/`はユーザの環境に応じて読み替えること。

## Knativeのインストール要件

ここではローカル環境におけるKnative v1.13 のインストール要件を示す。

* 3CPUと4GBのメモリを備えた1ノードクラスタが構築できること
  * kindを用いるため、ホストマシンのスペックが3CPU,4GBメモリと考えて良い

詳しくは[公式ドキュメント](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/)を参照すること。

## Knative CLIのインストール

Knative CLIは Knative APIを呼び出しKnativeを操作するためのクライアントツール。  
具体的には、Knative CLIを用いてアプリケーションをK8sへデプロイするなどのユースケースがある。  
これは、ユーザがKnative用のマニフェストを作成し、これをkubectlコマンドを用いてK8sへデプロイすることと同等である。

Knative CLIは https://github.com/knative/client/releases からダウンロードできる。  
ダウンロードするバージョンは適時 最新のものを指定するなど、読み替えること。

```
wget https://github.com/knative/client/releases/download/knative-v1.13.0/kn-linux-amd64
mv kn-linux-amd64 kn
chmod +x ./kn
mv ./kn /paht/to/bin/kn
```

## Knative Operatorプラグインのインストール

Knative Operatorとは、Knativeが提供するカスタムリソースとカスタムコントローラをパッケージ化したもの。

カスタムリソースとは、K8sが持つリソースではなく独自定義したリソースのこと、またはK8sがその独自リソースを追加できる機能を指す。  
カスタムコントローラとは、カスタムリソースを管理（具体的にはカスタムリソース上のオブジェクトを監視、必要に応じて更新）するものまたは機能を指す。

Knative OperatorをK8sにインストールするために、Knative CLIにKnative Operator CLIプラグインを導入する。

https://github.com/knative-extensions/kn-plugin-operator/releases からダウンロードできる。  
ダウンロードするバージョンは適時 最新のものを指定するなど、読み替えること。

```
wget https://github.com/knative-extensions/kn-plugin-operator/releases/download/knative-v1.13.0/kn-operator-linux-amd64
kn-operator-linux-amd64 kn-operator
chmod +x ./kn-operator
mkdir -p ~/.config/kn/plugins
mv kn-operator ~/.config/kn/plugins/.
```

下記コマンドを実行してヘルプが表示されることを確認する。

```
kn operator -h
```
以下のような結果が得られればOK。

```
kn operator: a plugin of kn client to operate Knative components.
For example:
kn operator install
kn operator install -c serving
kn operator install -c eventing

Usage:
  kn [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  configure   Configure the Knative Serving or Eventing
  enable      Enable the ingress for Knative Serving and the eventing sources for Knative Eventing
  help        Help about any command
  install     Install Knative Operator or Knative components
  remove      Remove the ingress for Knative Serving
  uninstall   Uninstall Knative Operator or Knative components

Flags:
  -h, --help   help for kn

Use "kn [command] --help" for more information about a command.
```

## K8sクラスタの構築

kindで作成するクラスタの設定ファイルである`clusterconfig.yml`を作成する。

```
cat > clusterconfig.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
    ## expose port 31080 of the node to port 8080 on the host
  - containerPort: 31080
    hostPort: 8080
    ## expose port 31443 of the node to port 8443 on the host
  - containerPort: 31443
    hostPort: 8443 
EOF
```

前述で作成したファイルを指定してkindコマンドを実行する。

```
kind create cluster --name knative --config clusterconfig.yaml
```

クラスタ情報は下記コマンドで確認できる。

```
kubectl cluster-info --context kind-knative
```

以下のような結果が得られればOK。

```
Kubernetes control plane is running at https://127.0.0.1:39549
CoreDNS is running at https://127.0.0.1:39549/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

`kubectl`コマンドがインストールされていない場合は、https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ などを参考にインストールすること。

## Knative opratorのインストール

下記コマンドを実行しK8sにKnative Operatorをインストールする。  
`NKATIVE_VERSION`は https://github.com/knative/client/releases などから最新バージョンまたはインストール対象バージョンを確認すること。  
基本的にKnative CLIのバージョンに合わせれば良い。

なお、`kn`コマンドは`kn --help`、`kn operator --help`、`kn operator install --help`で確認できる。

```
export KNATIVE_VERSION=v1.13.0
kn operator install -n knative-operator -v ${KNATIVE_VERSION}
```

インストールしたKnative Operatorの稼働状況を確認するには、次のコマンドを実行する。

```
kubectl get deployment knative-operator -n knative-operator 
```

以下のような結果が得られればOK。

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
knative-operator   1/1     1            1           16m
```

その他の確認方法とその結果をまとめて示す。

```
kubectl get pods -n knative-operator 
NAME                                READY   STATUS    RESTARTS   AGE
knative-operator-554b9cd5b6-dtxpw   1/1     Running   0          18m
operator-webhook-6fb777c79b-rw4td   1/1     Running   0          18m
```

* knative-operator: Knative Operatorが提供するカスタムコントローラで、Knative{Serving,Eventing}を監視する
* operator-webhook: KnativeのリソースやConfigMapの検証とデフォルト設定を行うもの（実体は Admission Webhook というもの）

Knative-operatorはKnative Serving,Knative Eventingの監視の他に、ConfigMapの更新も行う。

Admission WebhookはK8s APIのリクエストを許可するかしないかを判断する仕組み。

## Knative Servingのインストール

Knative Operatorインストール後、Knative Servingをインストールする。

```
kn 
```

## Knative Servingの別のインストール方法

なおyamlファイルをK8sに適用することも可能（上記でインストール済みであれば次のコマンドは実施不要）。

```
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-core.yaml
```

詳細は、 https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#verifying-image-signatures を参考にすること。
