# デザインパターン 03 (WEB/DB+VPCルータ構成)
さくらのクラウドで、 WEB/DB 構成でサーバを作成し、NATゲートウェイ兼保守ラインとして VPCルータ(スタンダード)を配置するためのコードです。  
お好みで VPCルータに VPN の設定も可能ですが、その場合は WEBサーバのデフォルトゲートウェイは VPCルータを向いていないことから、別途 WEBサーバ内にルーティングの設定が必要となる場合があります。  

## サンプル構成図
![](img/sample_03.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjUscToxfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfSx7cDoxLHE6MSxkaTpbe3A6NSxxOjF9XSwib3MiOm51bGwsbGE6bnVsbCx3YTpudWxsLGlwaG86ZmFsc2V9XSxzdzpbe3A6MSxxOjF9XSx2cDpbe3A6MSxxOjEsd2E6bnVsbH1dfX0=)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/03_shared_internet_web_db_vpc/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* デザインパターン 1/2 の備考も参照ください。

* インターネット接続するサーバ 1台(WEB)と、スイッチにのみ接続するプライベートなサーバ 1台(DB)、そして VPCルータ(スタンダード)を NATゲートウェイ兼保守ラインとして作成します。  
VPCルータはファイアウォールなのだから、WEBサーバも保護したらどうかと思うかもしませんが、そうしてしまうと、VPCルータの持つ 1個のグローバルIP アドレスのみしか存在しない構成になります。  
それで足りる場合(VPN経由のみでの利用や、ポートフォワーディングのみの利用で問題無い場合)は、WEBサーバを count=0 とし、DBサーバ側を count=2 として作成して、完全な NAT構成にすることは可能です。  
要件次第となります。  
複数のグローバルIP が必要となる場合は、デザインパターン 4 を確認してください。  

* 保守ラインを作ったので、パケットフィルタからは直接WEBサーバにログインするポリシーは削除しています。  

* 後述のとおり、本構成では DBサーバが WEBサーバへの SSHログイン時の踏み台を兼ねる形になってしまっています。  
これを避けたい場合は、デザインパターン 1/2 同様のパケットフィルタの設定に戻し、直接WEBサーバにログインするか、VPCルータに VPN の設定を実施し、VPN経由で各サーバにログインすることを検討してください。  
リモートアクセスVPN のように、クライアントにも同じプライベートネットワークの IP が割り当てられる場合は、問題無く通信が可能ですが、サイト間VPN のように、別のプライベートネットワークとなる場合は、WEBサーバには別途ルーティングの設定を実施する必要があります。  

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `vpc_router01_ip` が出力されますので、そのグローバルIPアドレスに対して SSH接続できることをご確認ください。  
VPCルータにてポートフォワーディングを設定していますので、DBサーバ側にはそれでログインし、WEBサーバ側には ssh ProxyCommand を利用した多段ssh をします。
```
$ ssh -p 10022 -i .ssh/sshkey sakura-user@VPCルータのグローバルIPアドレス
$ ssh -i .ssh/sshkey -o ProxyCommand='ssh -p 10022 -i .ssh/sshkey sakura-user@VPCルータのグローバルIPアドレス -W %h:%p' sakura-user@192.168.1.10
```

* サーバを 1台ずつ作成するコードですが、変数 `server01/02` の `count` を変更することで、まとめて複数台作成が可能です。  
その他、変数のパラメータを変更することで、スペックの変更などが可能です。  

## 参考
https://manual.sakura.ad.jp/cloud/network/vpc-router/about.html  
https://manual.sakura.ad.jp/cloud/network/vpc-router/vpc-remoteaccess.html  
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/resources/vpc_router  
