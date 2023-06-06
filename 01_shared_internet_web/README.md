# デザインパターン 01 (サーバ 1台)
さくらのクラウドで、サーバを 1台作成するためのコードです。  

## サンプル構成図
![](img/sample_01.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjUscToxfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfV19fQ==)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/01_shared_internet_web/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* さくらのクラウドでは、「インターネットに接続」するようにサーバを作成すると、サーバがグローバルIPアドレスを 1個持つ形で作成されます。  
複数のグローバルIP はサポートされません。1台で複数必要になる場合は、「ルータ＋スイッチ」というリソースを作成してください。  
そうすると、CIDR単位でグローバルIP を契約でき、自由に割り振ることができるようになります。

* 本コードでは、変数 `server01` の `os` に指定する文言により、その時点の最新のアーカイブが利用されるようにしています。  
(MiracleLinux8/9,AlmaLinux8/9,RockyLinux8/9,Ubuntu20.04/22.04)  
利用するアーカイブは、 `data.tf` にてタグをフィルタすることで指定しています。  
たとえば以下コマンドで Linux のアーカイブを検索することができますので、利用したい特定のアーカイブがあり、固定したい場合などは、タグでフィルタするのではなく、ID でフィルタすることも可能です。  
```
usacloud iaas archive list | jq '.[] | select(.Tags[]|contains("os-linux"))'
```

* 利用するゾーンは `default_zone` という変数で東京第2ゾーン(tk1b)を指定しています。  
本コード作成時点では、一部ゾーンには作成可能なスイッチの数に制限があるようなので、基本的にはここか石狩第2ゾーン(is1b)を使うのがよさそうです。  
ゾーンを変更する場合は、`default_zone` を変更しつつ、 変数 `zones` の中も追加もしくは変更するようにしてください。  
本コードでは関係ありませんが、複数ゾーンにまとめてサーバを作るときなどのために、ディスク作成時に指定するアーカイブをゾーン名を指定して変更することができるように、 `disk.tf` や `data.tf` はあえてこういった作りにしています。

* AWS でいうところの SecurityGroup に相当するファイアウォールが無いため、パケットフィルタという機能を使っています。  
実行環境の IPアドレスからのみ SSHアクセスを許可するようにしつつ、HTTP/ICMP は開放するようにしています。  
ステートレス動作のため、自発通信時の戻りパケット用のポート開放も必要になるので、注意してください。  

* 各種リソースの名前やタグの管理のために、 `terraform-null-label` というモジュールを使っています。  
管理がしやすくなるので、こういったものを使って統一することをおすすめします。

* サーバ作成時に、ちょっとした処理を自動実行させるために、スクリプトという機能を使っています。  
しっかりと構築をする場合は別途 Ansible を使うべきですが、パラメータを指定することで以下あたりを手軽に実行できるようにしており、RHEL系(MiracleLinux/AlmaLinux/RockyLinux)や Ubuntu(20.04/22.04)にて動作するものを用意しています。  

 1. ユーザの作成(RHEL系のみ。rootユーザしか作成されないため、サーバ作成時に指定する SSH鍵とパスワードを使うユーザも別途作成する)
 1. 作成したユーザ、もしくは ubuntu ユーザはパスワード無しで sudo できるよう設定
 1. OS上のファイアウォール機能無効化
 1. 2個めのインターフェイスに対するプライベートIPアドレスの設定
 1. DSR型ロードバランサ利用時用のループバックインターフェイスへの VIP設定
 1. IPマスカレード設定
 1. OSのアップデート
 1. HTTPD のインストール(とホスト名記載の index.html 作成)

* DNS もさくらのクラウドで管理していると、レコードの設定や、サーバ作成時に逆引きホストの設定もあわせて実施することができます。  
今回はそのあたりはすべて省略していますが、必要に応じて利用ください。  
(DNS をさくらのクラウドで管理する場合、他のコードとは一緒にせず、単体で作成することをおすすめします。他のコードから該当ゾーンの編集をしたいときは、 `Data Source` を使ってリソースID を取得し、操作すればよいです)

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `server01_ip` が出力されますので、そのグローバルIPアドレスに対して SSH接続できることをご確認ください。
```
$ ssh -i .ssh/sshkey sakura-user@グローバルIP
```

* サーバを 1台作成するコードですが、変数 `server01` の `count` を変更することで、まとめて複数台作成が可能です。  
その他、変数のパラメータを変更することで、スペックの変更などが可能です。  

## 参考
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/data-sources/archive  
https://manual.sakura.ad.jp/cloud/network/packet-filter.html  
https://github.com/cloudposse/terraform-null-label  
https://manual.sakura.ad.jp/cloud/startup-script/about.html  
