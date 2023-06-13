# デザインパターン 05 (自動バックアップ&シンプル監視)
さくらのクラウドで、ディスクの自動バックアップやシンプル監視を設定するためのコードです。  
デザインパターン 1 をベースに、1台のサーバのディスクの自動バックアップと、シンプル監視による監視設定を実施しています。  

## サンプル構成図
![](img/sample_05.drawio.svg)

## 概算見積もり
[料金シミュレーション](https://cloud.sakura.ad.jp/payment/simulation/#/?state=e3N6OiJ0azFiIixzdDp7InVuaXQiOiJtb250aGx5IiwidmFsdWUiOjF9LHNpOiIiLGl0OntzZTpbe3A6MSxxOjEsZGk6W3twOjUscToxfV0sIm9zIjpudWxsLGxhOm51bGwsd2E6bnVsbCxpcGhvOmZhbHNlfV0sImF1dG9iYWNrdXAiOlt7cDoxLHE6MSxhcjp7cDoxLHE6M30sInRpbWVzUGVyV2VlayI6N31dfX0=)

## 利用方法
```
$ cd ~/work/sakura_design_pattern/05_autobackup_simplemonitor/
$ terraform init
$ terraform plan
$ make apply ※通常は terraform apply だが、初回のみ SSH用鍵ファイル作成のため
$ terraform destroy ※全リソース削除
```

## 備考
* デザインパターン 1 の備考も参照ください。  

* 自動バックアップについては、 `backup.tf` と variables.tf 内の変数 `variable "backup01"` を確認ください。

* ディスクのアーカイブを作成する、という作業を自動化してくれるサービスが「自動バックアップ」です。  
ただ、曜日しか指定できず、実行時間帯は選べないこと、1-10世代までしか指定できないこと、1TBのディスクサイズまでしか対象にできないこと、などの制限がありますので、必要に応じて自分で CLI や API などを使って自前のスクリプトで実装する(実行環境も別途必要になりますが)、といったことも候補に入るかもしれません。  
(とはいえ、アーカイブ自体が 1TB までしか対応していないので、ディスクサイズはどうにもなりません)

* 自動バックアップにより生成されるアーカイブは、本コードの管理対象には入りません。  
このため本コードを実行し、自動バックアップが動くことを確認してから、 `terraform destroy` を実行した場合、アーカイブが残り続けます。  
不要な課金につながってしまうため、アーカイブについては手動で削除するよう、ご注意ください。  
なお、 `autobackup-自動バックアップ設定のリソースID` のタグが付与された状態になるため、 CLI にて以下 1コマンドでまとめて削除することが可能です。
```
$ usacloud iaas archive delete autobackup-自動バックアップ設定のリソースID --zone tk1b
```

* シンプル監視については、 `monitor.tf` と variables.tf 内の変数 `variable "simple_monitor_source_network"` を確認ください。  
監視用に、 `filter.tf` も調整しています。  
PING/HTTP/SSH の監視を設定しています。  
なお、コントロールパネル上で作成した場合は、本来ならメールか Webhook どちらかの通知の有効化が必須なはずですが、 Terraform で作成する場合、どちらも無効での設定が可能でした。  
このため、あえてどちらも無効化して作成しています。(テストで不要な通知が飛ばないように)  
メールを有効化した場合、会員ID に登録してあるメールアドレスもしくは、コントロールパネルにて「メンテナンス・障害情報通知先のメールアドレス」に登録したメールアドレスのどちらかに送付されるようで、個別に指定することはできないようです。  
メールや Webhook での通知もテストする場合は、必要に応じてコードを変更ください。  

* 監視方法により、指定可能なパラメータは変わりますので、詳細はドキュメントや実際のコントロールパネルでの表示をご確認ください。  

* シンプル監視の詳細は、参考に記載したマニュアル等のドキュメントを確認いただくのが一番です。  
「概算見積もり」に費用が無いように見えますが、なんと無料です。(！！！)  
ただし、監視対象はグローバルIP アドレスを持つ、インターネット経由でアクセス可能なもののみとなります。  
このため、プライベートIP しか持たないなど、インターネット経由でのアクセスが不可だと監視できませんし、リソース監視などのサーバ内部の監視もできません。  
インターネット経由での外形監視のみとなるようですので、必要に応じて何か別の監視サービスを利用してください。  

* サーバは SSH鍵認証で入ることとしており、利用する鍵は Terraform で作成しています。  
Makefile を用意していますので、 `terraform apply` ではなく、 `make apply` としていただくことで、フォルダ内に .ssh フォルダを作成し、秘密鍵と公開鍵を作成します。  
作成後は `server01_ip` が出力されますので、そのグローバルIPアドレスに対して SSH接続できることをご確認ください。
```
$ ssh -i .ssh/sshkey sakura-user@グローバルIP
```

* サーバを 1台作成するコードですが、変数 `server01` の `count` を変更することで、まとめて複数台作成が可能です。  
その他、変数のパラメータを変更することで、スペックの変更などが可能です。  
サーバ台数が増えれば、自動バックアップの設定もその分増えますが、作成可能なリソースの上限が `5 設定` までですので、ご注意ください。

## 参考
https://manual.sakura.ad.jp/cloud/appliance/autobackup/index.html  
https://manual.sakura.ad.jp/cloud/storage/archive.html  
https://manual.sakura.ad.jp/cloud/payment/resource-limit.html  
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/resources/auto_backup  
https://manual.sakura.ad.jp/cloud/appliance/simplemonitor/index.html  
https://manual.sakura.ad.jp/cloud/controlpanel/settings/notification-mail-address.html  
https://registry.terraform.io/providers/sacloud/sakuracloud/latest/docs/resources/simple_monitor  