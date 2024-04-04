# デザインパターン 11 (LGWANコネクト構成)
さくらのクラウドで、LGWANコネクトの開発環境用の構成を作成するためのコードです。  
本番用ではありませんので、ご注意ください。  
本番用にも転用可能ですが、その場合はインターネット接続セグメント側のリソースと、それ以外のリソースで、作成するクラウドアカウントを分けるようにしてください。   
こちらのコードを実行すると、三層構造にサーバを 1台ずつ配置した構成ができあがります。  
VPCルータやローカルルータには、必要なスタティックルートやファイアウォールポリシー(SSH/Proxy/DNS用)が設定されます。  
サーバ内のネットワーク設定も、スタートアップスクリプトで実行するようになっています。  
ローカルルータ 1/2 台目相互のピア接続はコメントアウトしてありますので、全リソースの構築完了後に解除して実施してください。  
(循環参照になってしまうため、片側は Data Sources として参照するようにしています)  
また、~/.ssh/config に多段プロキシ用の設定を実施するようにしてあるため、2回目以降の apply実行は make を利用しないようにご注意ください。  
参考までにプロキシ設定および DNS設定、OSアップデートのプロキシ利用までを Ansible で自動化しています。  

## サンプル構成図
![](img/sample_11.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJpczFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjExLHE6MX1dLCJvcyI6bnVsbCxsYTpudWxsLHdhOm51bGwsaXBobzpmYWxzZX0se3A6MSxxOjEsZGk6W3twOjExLHE6MX1dLCJvcyI6bnVsbCxsYTpudWxsLHdhOm51bGwsaXBobzpmYWxzZX0se3A6MSxxOjEsZGk6W3twOjExLHE6MX1dLCJvcyI6bnVsbCxsYTpudWxsLHdhOm51bGwsaXBobzpmYWxzZX1dLHN3Olt7cDoxLHE6OH1dLGxvOlt7cDoxLHE6M31dLHZwOlt7cDoxLHE6NCx3YTpudWxsfV19fQ==)  
※LGWANコネクトおよびアンチウイルス、無害化処理等の費用は含まれないのでご注意ください。  

## 利用方法
```
★最初の実行
$ cd ~/work/sakura_design_pattern/11_lgwan_connect/
$ make init
$ make plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイルおよび .ssh/config 作成のため

★ローカルルータのピア接続実施のため、2回目の実行
$ vim localrouter.tf ※ `# comment out after local_router01/02` とつけている設定箇所のコメントを解除して、ローカルルータ間のピア接続を行う(3箇所)
$ terraform apply ※2回目以降の実行時は、make apply は使わないこと。でないと、~/.ssh/config に同じ内容が追記されていきます

★各アプリケーションの設定のため、Ansible 実行
$ cd ansible
$ ansible-playbook -i dev_hosts site.yml ※各サーバにプロキシおよび DNS、OSアップデートのプロキシ利用の設定を実施します

★削除
$ make destroy ※全リソース削除
```

## SSH接続用の設定
`userdata/addsshconfig` というファイルが置いてあり、`make apply` 実行時に `~/.ssh/config` に以下の内容が追記されるようになっています。  
```
Host internet
    Hostname VPCルータのグローバルIP
    Port 10022
    User sakura-user
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    IdentityFile ~/work/sakura_design_pattern/11_lgwan_connect/.ssh/sshkey
    ControlMaster auto
    ControlPath ~/.ssh/cp-%r@%h:%p
    ControlPersist 10m

Host gateway
    Hostname 192.168.4.10
    User sakura-user
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    IdentityFile ~/work/sakura_design_pattern/11_lgwan_connect/.ssh/sshkey
    ProxyJump internet

Host lgwan
    Hostname 192.168.6.2
    User sakura-user
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    IdentityFile ~/work/sakura_design_pattern/11_lgwan_connect/.ssh/sshkey
    ProxyJump gateway
```

## 備考
* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `vpc_router01_ip` が出力されます。  
~/.ssh/config に多段ログイン用の ProxyJump 設定をしてありますので、以下だけで各サーバにアクセス可能です。  
```
$ ssh internet
$ ssh gateway
$ ssh lgwan
```

## Ansible について
各サーバにて、以下の設定が実施されるようにしてあります。  
各サーバで DNS の名前解決ができるようにしつつ、プロキシを利用して RockyLinux 9 用に限定したドメインへのアクセスのみを許可する形で、dnf(yum)が可能なようにしています。  
  
### internet
* OSアップデートとパッケージのインストール(unbound/squid)
* unbound 設定
* squid 設定

### gateway
* dnf.conf 設定
* resolv.conf 設定
* OSアップデートとパッケージのインストール(unbound/squid)
* unbound 設定
* squid 設定

### internet
* dnf.conf 設定
* resolv.conf 設定
* OSアップデート

## 参考
https://docs.ansible.com/ansible/2.9_ja/index.html  
https://www.squid-cache.org/  
https://unbound.jp/unbound/  
