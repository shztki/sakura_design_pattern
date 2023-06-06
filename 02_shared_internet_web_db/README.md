# デザインパターン 02 (WEB/DB構成)
さくらのクラウドで、 WEB/DB 構成でサーバを作成するためのコードです。  

## サンプル構成図
![](img/sample_02.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjUscToxfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfSx7cDoxLHE6MSxkaTpbe3A6NSxxOjF9XSwib3MiOm51bGwsbGE6bnVsbCx3YTpudWxsLGlwaG86ZmFsc2V9XSxzdzpbe3A6MSxxOjF9XX19)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/02_shared_internet_web_db/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* デザインパターン 1 の備考も参照ください。

* インターネット接続するサーバ 1台(WEB)と、スイッチにのみ接続するプライベートなサーバ 1台(DB)を作成します。

* WEB サーバを NATゲートウェイ兼踏み台サーバとする作りにしています。  
しかし本来はサーバに複数機能を持たせるのではなく、単機能にする方が望ましいので、デザインパターン 3 でご紹介するように、別途 VPCルータ(スタンダード)を導入し、 NATゲートウェイ兼保守ラインのように使うのがよいかと思います。  
あるいは、DBサーバもインターネット接続させてグローバルIP を持たせつつ、パケットフィルタは DB用のものを別途作り、不要なポートを一切開放しないようにする、ということも考えられます。  
(ただしパケットフィルタはステートレス仕様のため、自発通信の戻り用のポート開放が必要な点は注意してください)  

* さくらのクラウドでは、スイッチ作成時にプライベートネットワークの指定は不要です。  
ただ、それでは管理しづらいため、あえてプライベートネットワークを変数に指定して、名前の一部にするようにしています。  
そしてサーバなど作成時にプライベート IPアドレスの指定が必要になる部分で、該当の変数を利用して第四オクテットだけを別途指定することで、統一された設定ができるようにしています。  
本コードでは `192.168.1.0/24` としており、WEBサーバは 192.168.1.10 から連番で、DBサーバは 192.168.1.50 から連番で IP を振るようにしています。  
( `variable "switch01"` の `name` で指定しています。ここを変えるだけで簡単にプライベートネットワークの変更が可能です)  

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `server01_ip` が出力されますので、そのグローバルIPアドレスに対して SSH接続できることをご確認ください。  
DBサーバ側には、 ssh ProxyCommand を利用した多段ssh をするのが楽です。
```
$ ssh -i .ssh/sshkey sakura-user@グローバルIPアドレス
$ ssh -i .ssh/sshkey -o ProxyCommand='ssh -i .ssh/sshkey sakura-user@グローバルIPアドレス -W %h:%p' sakura-user@192.168.1.50
```

* サーバを 1台ずつ作成するコードですが、変数 `server01/02` の `count` を変更することで、まとめて複数台作成が可能です。  
その他、変数のパラメータを変更することで、スペックの変更などが可能です。  

## 参考
https://manual.sakura.ad.jp/cloud/network/switch/about.html  
