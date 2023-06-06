# デザインパターン 04 (ルータ＋スイッチ/VPCルータ/WEB/DB構成)
さくらのクラウドで、専用のグローバルネットワークを構成し、VPCルータ(プレミアム)配下に WEB/DB をそれぞれ別のプライベートネットワークで作成するためのコードです。  

## サンプル構成図
![](img/sample_04.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjUscToxfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfSx7cDoxLHE6MSxkaTpbe3A6NSxxOjF9XSwib3MiOm51bGwsbGE6bnVsbCx3YTpudWxsLGlwaG86ZmFsc2V9XSxzdzpbe3A6MSxxOjJ9XSxybzpbe3A6MSxxOjEsImlwIjp7cDoxLHE6MX19XSx2cDpbe3A6MixxOjEsd2E6bnVsbH1dfX0=)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/04_dedicated_internet_web_db_vpc/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* デザインパターン 1/2 の備考も参照ください。

* ルータ＋スイッチというサービスを使い、専用のグローバルIP の CIDR と帯域を指定します。  
そしてそのグローバルネットワークの最上位に VPCルータ(プレミアム以上)を配置し、サーバはすべてプライベートIP のみを持ち、ファイアウォール配下に置く NAT構成としています。  
WEBサーバに対しては、スタティックNAT を使って直接通信可能となっています。   
本コードでは WEB/DB でそれぞれプライベートネットワークを分けていますが、もちろん 1つのネットワークでも問題ありません。  
要件次第となります。  
なお、VPCルータはあくまでも簡易的なファイアウォールアプライアンスとなります。  
Fortigate などのメーカー製アプライアンスと異なり、設定可能な項目やパラメータは少なく、機能面では物足りない部分があります。  
(グローバルIP のエイリアスを 19個までしか持てないため、それ以上に使いたい場合、追加の VPCルータ(プレミアム以上)を構築し、そちらを使うサーバはデフォルトゲートウェイもそちらに向ける、といった工夫が必要になります。/27 以上の CIDR にした場合に、server01 の count を 20以上にすると、動的に設定しているスタティックNAT 部分がエラーになりますので、注意して下さい)  
Terraform のコード上で設定までできるのは VPCルータのメリットですが、機能面で要件に合わない場合は、メーカー製のアプライアンスを検討してください。  
ただし、コードで内部の設定までは構築できなくなるため、ファイアウォールまでを作るコードと、サーバを作るコードは分けて管理して、ファイアウォールを作成した後、初期設定を手動で個別に終えた後に、サーバを作るコードを実行する、といった工夫は必要になります。  

* このコードではあえて VPCルータに DBサーバ向けのポートフォワーディングや、VPN の設定は実施していません。  
このため、SSH接続のサンプルはすべて WEBサーバ経由で接続するようにしています。  
本来はポートフォワーディングや VPN で運用できるようにした方がよいと思いますので、要件に合わせて変更してください。  

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `router_ip_addresses` が出力されますので、先頭から 4個目以降のグローバルIPアドレスに対して SSH接続できることをご確認ください。  
VPCルータにてスタティックNAT を設定していますので、WEBサーバ側にはそれでログインし、DBサーバ側には ssh ProxyCommand を利用した多段ssh をします。
```
$ ssh -i .ssh/sshkey sakura-user@ルータ＋スイッチで確保したグローバルIPアドレスの 4個目
$ ssh -i .ssh/sshkey -o ProxyCommand='ssh -i .ssh/sshkey sakura-user@ルータ＋スイッチで確保したグローバルIPアドレスの 4個目 -W %h:%p' sakura-user@192.168.2.50
```

* VPCルータの作成には時間がかかります。  
このため、OS のアップデートやパッケージのインストールなど、通信が必要な処理をスクリプトで実行させても、タイムアウトして失敗になります。  
こういった構成では、 OS内部の構築には Ansible を利用しましょう。  
RHEL系の OS用に(といっても動作確認は RockyLinux9 しか試してませんのでご了承ください)、WEB用にパッケージをアップデートして、Apache をインストールして、設定ファイルを置き換えつつ、ホスト名を記載した index.html ファイルを置いておくものと、DB用にパッケージをアップデートして、MariaDB をインストールして、ユーザーとデータベースを作成するものは用意してあります。  
以下のとおり、 `dev_hosts` ファイルの `GlobalIPAddress` のところに、対象となるグローバルIPアドレスを入れてもらい、WEB用/DB用それぞれのコマンドを実行すればセットアップされます。  
複数台ある場合は、それぞれのホストのところに複数行記載すれば OK です。  
```
$ cd ansible
$ cat dev_hosts
[web]
GlobalIPAddress interpreter_python=/usr/bin/python3 ansible_user=sakura-user ansible_ssh_private_key_file=..//.ssh/sshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[db]
192.168.2.50 interpreter_python=/usr/bin/python3 ansible_user=sakura-user ansible_ssh_private_key_file=..//.ssh/sshkey ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o IdentityFile=..//.ssh/sshkey sakura-user@GlobalIPAddress"'

$ ansible-playbook -i dev_hosts web.yml
$ ansible-playbook -i dev_hosts db.yml
```

* サーバを 1台ずつ作成するコードですが、変数 `server01/02` の `count` を変更することで、まとめて複数台作成が可能です。  
その他、変数のパラメータを変更することで、スペックの変更などが可能です。  

## 参考
https://manual.sakura.ad.jp/cloud/network/switch/about.html#id6  
https://manual.sakura.ad.jp/cloud/network/vpc-router/about.html  
https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_user_module.html  
https://docs.ansible.com/ansible/latest/collections/community/mysql/mysql_db_module.html  
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/resources/vpc_router  
