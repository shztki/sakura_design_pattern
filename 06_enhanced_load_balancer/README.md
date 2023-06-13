# デザインパターン 06 (エンハンスドロードバランサ、サーバ 2台)
さくらのクラウドで、エンハンスドロードバランサを使って、WEBサーバ 2台にアクセスを分散するための構成を作成するコードです。  

## サンプル構成図
![](img/sample_06.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjIsZGk6W3twOjUscToyfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfV0scm86W3twOjEscToxLCJpcCI6e3A6MSxxOjF9fV0scHI6W3twOjYscToxfV19fQ==)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/06_enhanced_load_balancer/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* デザインパターン 1/4 の備考も参照ください。  

* 無効化およびコメントにしていますが、さくらのクラウド上で DNS(ゾーン) を管理している場合、レコードの設定や証明書の作成、設定をまとめて実施できますので、`dns_data.tf.disable` と variables.tf 内の変数 `my_domain` を用意してあり、 `elb.tf` 内にも HTTPS利用時用の設定が残してあります。  
必要に応じて利用ください。  

* 本来であれば、共有セグメント所属のサーバでよかったのですが、あえて「ルータ＋スイッチ」配下になるようにしています。  
これにより、エンハンスドロードバランサで実サーバを指定する際に、サーバの IPアドレスを参照するのではなく、「ルータ＋スイッチ」で確保した IPアドレスを指定することができるようになるため、サーバ作成よりも先にエンハンスドロードバランサの作成が可能となります。  
そうすると、パケットフィルタで TCP80 へのアクセス元にエンハンスドロードバランサのプロキシ元ネットワークを指定できるようになり、よりセキュアです。  
なお、共有セグメント所属のサーバとした場合は、このような設定にすると循環参照によりエラーとなるため、パケットフィルタで TCP80 へのアクセス元を限定したい場合は、一度 Any で指定して構築を完了させた後に、改めて `sakuracloud_proxylb.elb01.proxy_networks` を指定するようにしましょう。  
なお、こちらはリストとなっており、エンハンスドロードバランサの設置先リージョンを「自動(エニーキャスト)」にした場合は、複数入りますので、ご注意ください。  

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `server01_ip` が出力されますので、そのグローバルIPアドレスに対して SSH接続できることをご確認ください。
```
$ ssh -i .ssh/sshkey sakura-user@グローバルIP
```

* エンハンスドロードバランサはプロキシ型の L7ロードバランサです。  
このため、Apache等 WEBサーバソフトウェアを標準状態のままにすると、ログに記録されるアクセス元IP は、常にロードバランサのものとなります。  
また、ヘルスチェックのアクセスを除外しないと、大量のログが記録されます。  
こういった構成では、 OS内部の構築には Ansible を利用しましょう。  
RHEL系の OS用に(といっても動作確認は RockyLinux9 しか試してませんのでご了承ください)、WEB用にパッケージをアップデートして、Apache をインストールして、ログの設定を調整した設定ファイルに置き換えつつ、ホスト名を記載した index.html ファイルを置いておく処理を用意してあります。  
以下のとおり、 `dev_hosts` ファイルの `GlobalIPAddress1/GlobalIPAddress2` のところに、対象となるサーバのグローバルIPアドレスを入れてください。  
また `roles/httpd/files/httpd.conf.j2` 内の `ProxyNetworks` のところ(2箇所)を、Terraform で構築後に出力される `elb01_proxy_networks` の CIDR に変更して、コマンドを実行すればセットアップされます。  
ログについては、 `X-Real-IP` を使い、 `%h` から `%a` に変えることで記録するようにしていますが、 `X-Forwarded-For` を直接追加してもらってもだいじょうぶです。  
```
$ cd ansible
$ cat dev_hosts
[web]
GlobalIPAddress1 interpreter_python=/usr/bin/python3 ansible_user=sakura-user ansible_ssh_private_key_file=..//.ssh/sshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'
GlobalIPAddress2 interpreter_python=/usr/bin/python3 ansible_user=sakura-user ansible_ssh_private_key_file=..//.ssh/sshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'

$ cat roles/httpd/files/httpd.conf.j2 | grep "ProxyNetworks"
RemoteIPTrustedProxy ProxyNetworks
<If "-R 'ProxyNetworks'">

$ ansible-playbook -i dev_hosts web.yml
```

* Terraform での構築後に出力される `elb01_fqdn` にアクセスすると、各WEBサーバにアクセスが分散されていることが確認できます。  

* サーバを 2台作成するコードですが、変数 `server01` の `count` を変更することで、台数の変更が可能です。  
その他、変数のパラメータを変更することで、スペックの変更なども可能です。  

## 参考
https://manual.sakura.ad.jp/cloud/appliance/enhanced-lb/index.html  
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/resources/proxylb  
