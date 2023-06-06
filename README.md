
# さくらのクラウド IaC デザインパターン
さくらのクラウドを Terraform で構築自動化するためのデザインパターン集です。  
前提として以下ツールの実行環境が必要です。

+ Terraform
+ Ansible
+ usacloud
+ AWS CLI
+ Git
+ jq
+ direnv
+ pass
+ tig

実行環境の選択肢はいくつかありますが、手軽でかつ手元で操作できるということで、Windows を使っているなら WSL がおすすめです。  
以下に参考程度に情報記載しておきますが、さまざまな情報が WEB で公開されているので、それらを参考にしながら、自分の使いやすいように環境構築してください。

## WSL2 で Ubuntu22.04 の環境を用意する
* まずはターミナルということで、 Windows Terminal をインストールしてください。  
https://learn.microsoft.com/ja-jp/windows/terminal/install

* WSL2 をはじめて使う方は、以下などの情報を参考にインストールしてください。(Windows PorwerShell のコマンドラインでも、Microsoft Store でもインストール可能)  
https://learn.microsoft.com/ja-jp/windows/wsl/install

* すでに利用中で、別環境を用意したい場合は以下の手順を実行してください。

1. 以下ファイルを任意の場所にダウンロードする。(ここでは `C:\Users\ユーザー名\Downloads` とする)  
https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz

1. Windows Terminal にて Windows PorwerShell を開き、以下コマンドで別名でインポートする。( `ユーザー名` のところを適宜変更ください)
    ```
    wsl --import Ubuntu-22.04-002 ./Ubuntu-22.04-002 C:\Users\ユーザー名\Downloads\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz
    ```
    通常インストールするものは `C:\Users\ユーザー名\AppData\Local\Packages\` 配下にありますが、インポートしたものは `%USERPROFILE%` 配下にあります。  
    エクスプローラー上でディストリビューションの中身を確認するには `\\wsl.localhost` にアクセスすればよいのは同じです。

1. Windows PorwerShell で以下コマンドを実行し、インストール済みの一覧を確認しつつ、該当のディストリビューションにログインしてください。
    ```
    wsl -l -v
    wsl -d Ubuntu-22.04-002
    ```

1. Linux内で以下コマンドを実行し、sudo 可能なユーザーを作成します。( `ユーザー` のところを適宜変更ください)
    ```
    # useradd -m -G sudo -s /bin/bash ユーザー
    # sudo passwd ユーザー
    # exit
    ```

1. 最後に Windows PorwerShell で以下コマンドを実行し、該当ディストリビューションのデフォルトユーザーを変更します。( `ユーザー` のところを適宜変更ください)
    ```
    Function WSL-SetDefaultUser ($distro="Ubuntu-22.04-002", $user="ユーザー") { Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq $distro | Set-ItemProperty -Name DefaultUid -Value ((wsl -d $distro -u $user -e id -u) | Out-String); }; WSL-SetDefaultUser; Remove-Item Function:WSL-SetDefaultUser;
    ```

* Windows Terminal を起動し直せば、ターミナルの選択肢にインストールしたディストリビューションが表示されますので、それを選択してログインしてください。


## 開発環境をセットアップする
環境を作るときに考えることのひとつとして、いかにユーザーディレクトリに閉じた環境にできるか、というところがあります。  
Mac でよく homebrew というのを見かけますが、ユーザー権限の範囲で、ユーザーディレクトリの中で、完結できるように構成することも重要ではあります。(削除して作り直したいときに、OS のインストールからやり直さずに済むなど、メリットがある)  
ただ、あまりにそれにこだわっても、意味は無いように思います。(どうしても OS上の機能としてインストールするべきものもでてくるので、必要以上に固執してもデメリットにしかならない)  
そこまで影響を排除したいなら、コンテナ化するべきだと思います。  
プログラムの実行環境についても、バージョンごとに分ける(env系のツール利用)など、したいところではありますが、開発者ではないので、あまりそこに工数を割くのもどうかな、とも思います。  
そういったさまざまな検討課題を通り過ぎて、とりあえず実行していることの一部を、以下に記載します。  
参考程度に、自分の使いやすいように環境構築してください。  

* 私は環境構築を全部 Ansible でスクリプト化しているため、まずはその実行環境を準備するため、以下を実施しています。  
意図としては、ひとまず OS を最新にしつつ、Ubuntu 22.04 には Python 3 がインストールされているので、 pip を追加して virtualenv をインストールし、以降利用する Python環境は仮想的に分けておくことで、OS側の Python になるべく手を入れない、かつ今後別途きれいな Python環境を使いたいときに、環境を分けることができるようにしています。  
以前は pyenv を使っていたこともありますが、そもそも開発者ではないため、そこまで頻繁に利用もしないので、ここに落ち着いた感じです。  
そして、その作った環境内に Ansible をインストールしています。  
開発環境構築の自動化目的もありますが、クラウド上に作ったサーバに対しての自動セットアップにも使えます。  
```
$ sudo apt update
$ sudo apt upgrade -y
$ sudo apt install -y python3-pip
$ pip3 install virtualenv
$ mkdir ~/.venv
$ chmod -R 0755 ~/.venv
$ python3 -m virtualenv ~/.venv/latest
$ source ~/.venv/latest/bin/activate
$ pip install ansible
```

* 次に、最低限利用するツール類のインストールです。  
最新の情報は、各ツールのドキュメントを参照いただくべきですが、この文章作成時点では以下でインストール可能です。  
このように Ansible化しておきつつ、その他作成したコードも含め、GitHub のプライベートリポジトリで管理しておくと、環境の再構築が非常にやりやすくなりますし、PC を変えるなどで困ることも無くなるので、おすすめです。  
作り方によっては、Ansible を再実行するだけで OS や各ツールをすべて最新化させることもできますので、環境の管理も楽になります。  
なお、今回のコードではすべて最新で構築するようにしていますが、Terraform に関してはバージョン指定でダウンロードして、配置する、というのもよいと思います。  
過去にバージョンが上がることで動かなくなったり、コードの書き換えが必要となることもあったので、意図したバージョンを利用できるようにしておくのも、運用上必要になることはあると思います。  
```
$ mkdir ~/work
$ cd ~/work
$ git clone https://github.com/shztki/sakura_design_pattern
$ cd sakura_design_pattern/00_dev_setup_ansible/
$ ansible-playbook -i dev_hosts wsl_ubuntu_22.yml --ask-become-pass
$ source ~/.bashrc
```

* 最後に、さくらのクラウドの APIキーを作成しましょう。  
https://manual.sakura.ad.jp/cloud/api/apikey.html#id3  
作成したものは、以下のようにして登録します。  
あえてデフォルトとしての登録はせず、プロファイルを指定しないと使えないようにします。  
これは複数の異なるアクセスキーを使い分けることを念頭に、うっかり作業ミスをしないために、このようにしています。  
その後、作業ディレクトリに .envrc を用意し、環境変数に該当プロファイルの値をセットするようにします。  
direnv を利用することで、このようにディレクトリ単位で環境を自由に切り替えられるようになるため、非常に便利です。  
作業フォルダ外に遷移すると、環境変数はリセットされるため、CLI実行時に意図的にプロファイルを指定しないと動作しなくなるので、作業ミス防止が期待できます。  
AWS CLI もそうですが、デフォルトのプロファイルを設定するのはあまりおすすめしません。  
もっともこれだけでなく、より気づきやすく、作業しやすくするために、シェルを fish に変えたり、powerline font 等を使って画面をカラフルにしたり、いろんな工夫をするとよいと思います。  
```
$ usacloud config プロファイル名

Setting SakuraCloud API Token =>
        Enter token: アクセストークン

Setting SakuraCloud API Secret=>
        Enter secret: アクセストークンシークレット

Setting SakuraCloud Zone=>
        Enter Zone[tk1a/tk1b/is1a/is1b/tk1v]: tk1b

Setting Default Output Type=>
        Enter Default Output Type[table/json/yaml]: json

Written your settings to /home/ユーザー/.usacloud/プロファイル名/config.json

Would you like to switch to profile "プロファイル名"?(y/n) [n]: n

$ cd ~/work/sakura_design_pattern/
$ echo "sakuracloud_profile プロファイル名" > .envrc
$ direnv allow
$ env | grep SAKURA
```

* 問題無く設定できたか、コマンドを実行して確認してみましょう。  
環境変数がセットされるので、プロファイルを指定しなくても、CLI や API の実行が可能です。  
```
$ usacloud iaas zone list
$ curl -u $SAKURACLOUD_ACCESS_TOKEN:$SAKURACLOUD_ACCESS_TOKEN_SECRET https://secure.sakura.ad.jp/cloud/zone/is1a/api/objectstorage/1.0/fed/v1/clusters | jq
```

* 補足として、オブジェクトストレージについては、まず以下の手順で利用を開始します。  
https://manual.sakura.ad.jp/cloud/objectstorage/about.html#id8  
途中、アクセスキーが表示されますが、これは最上位権限のものとして控えておくのみとし、実際に利用するのは以下で作成するパーミッションにしましょう。  
https://manual.sakura.ad.jp/cloud/objectstorage/about.html#objectstrage-about-permission  
ただし、パーミッションで作成したアクセスキーは、指定したバケットに対する操作のみが行えるアクセスキーですので、バケット一覧を取得するといったことはできないので、バケットが無い状態では CLI の動作確認もできません。(かつバケット作成すると課金されてしまいます)  
そのため、試しづらいところですが、バケットを作成し、それを操作するパーミッション作成時の AWS CLI への登録と、その後のコマンド実行は以下のようになります。  
(環境変数に自動的にセットするようにすることで、プロファイル名の指定は省略できますが、エンドポイントURL は毎回コマンド実行時に指定する必要があります)  
```
$ aws configure --profile プロファイル名
AWS Access Key ID [None]: アクセスキーID
AWS Secret Access Key [None]: シークレットアクセスキー
Default region name [None]: jp-north-1
Default output format [None]: json

$ cd ~/work/sakura_design_pattern/
$ echo "aws_profile プロファイル名" >> .envrc
$ direnv allow
$ env | grep AWS

$ aws --endpoint-url=https://s3.isk01.sakurastorage.jp s3 ls s3://バケット名/
$ aws --endpoint-url=https://s3.isk01.sakurastorage.jp s3api get-bucket-location --bucket バケット名
```

* 構築時に利用するパスワードなどの機微情報は、コードに直接書くべきではありません。  
他に良い方法がないか自分も探し続けているところですが、今のところは pass コマンドを利用して登録しておき、direnv にて環境変数に登録する形にしています。  
以下の流れで初期化したあと、構築時に設定するサーバログイン用のパスワードを登録しておきましょう。  
なお GPG鍵作成途中に Passphrase を設定しますが、この Passphrase は、以後該当ディレクトリに遷移するたびに、direnv で pass コマンドが呼び出されるときに入力することになりますので、忘れないように注意してください。
```
$ gpg --gen-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Note: Use "gpg --full-generate-key" for a full featured key generation dialog.

GnuPG needs to construct a user ID to identify your key.

Real name: 名前入力
Email address: メールアドレス入力
You selected this USER-ID:
    "名前 <メールアドレス>"

Change (N)ame, (E)mail, or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /home/ユーザー/.gnupg/trustdb.gpg: trustdb created
gpg: key F813DF0DCD3FB9ED marked as ultimately trusted
gpg: directory '/home/ユーザー/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/ユーザー/.gnupg/openpgp-revocs.d/公開鍵.rev'
public and secret key created and signed.

pub   rsa3072 2023-05-29 [SC] [expires: 2025-05-28]
      公開鍵
uid                      名前 <メールアドレス>
sub   rsa3072 2023-05-29 [E] [expires: 2025-05-28]

$ pass init 公開鍵
mkdir: created directory '/home/ユーザー/.password-store/'
Password store initialized for 公開鍵

$ pass insert terraform/sakuracloud/default_password
mkdir: created directory '/home/ユーザー/.password-store/terraform'
mkdir: created directory '/home/ユーザー/.password-store/terraform/sakuracloud'
Enter password for terraform/sakuracloud/default_password:
Retype password for terraform/sakuracloud/default_password:

$ cd ~/work/sakura_design_pattern/
$ echo "terraform_sakuracloud_variables_set" >> .envrc
$ direnv allow
$ env | grep TF_
```

* Terraform Cloud について  
https://www.hashicorp.com/products/terraform?product_intent=terraform  
https://developer.hashicorp.com/terraform/cli/cloud/settings  
Terraform でリソースを作成すると、state ファイルが作成され、構成が管理されます。  
ただ、これをローカルに持ってしまうと、PC を変えた時などに困ることになりますし、複数人で管理するときには問題になります。  
同じ state ファイルを操作できるように、 remote state 環境にしておくと、より安心です。  
作成するリソースが少なければ、無償で利用できますので、 Terraform Cloud を利用するのもよいかもしれません。  
参考までですが、もし利用する場合は、環境変数に以下を登録し、 main.tf で `#cloud {}` の部分をコメントアウトして、ご利用ください。
```
export TF_CLOUD_ORGANIZATION=オーガナイゼーション
export TF_CLOUD_HOSTNAME=app.terraform.io
export TF_WORKSPACE=ワークスペース
export TF_TOKEN_app_terraform_io=`pass terraform/cloud/token`
```

* 上記について、同様のことを AWS の S3 に置き場所となるバケットを作りつつ、 DynamoDB を使ってロック機能を実装することで、実現する方法もあります。  
またロック不要であれば、さくらのオブジェクトストレージに作成したバケットを指定して、保存することも可能です。  
その場合は main.tf の以下部分をコメントアウトして、バケット名やキー名は変更して、ご利用ください。
```
  #backend "s3" {
  #  bucket                      = "bucket-name"
  #  key                         = "01_design_pattern/terraform.tfstate"
  #  region                      = "jp-north-1"
  #  endpoint                    = "https://s3.isk01.sakurastorage.jp"
  #  skip_region_validation      = true
  #  skip_credentials_validation = true
  #  skip_metadata_api_check     = true
  #  force_path_style            = true
  #}
```

* 余談ですが、エディタには Visual Studio Code をおすすめします。  
https://code.visualstudio.com/  
https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl  
私はこれをふつうに PC側にインストールしており、メモ帳代わりのエディタソフトとして使っています。  
こちらに WSL用のプラグインを追加すると、直接 WSL2 の Ubuntu22.04 の中のファイルも操作できるようになります。  
基本はターミナル上で vim を使って作業することが多いですが、README の編集など一部の作業はエディタの方が効率がよいので、 VS Code を併用してます。  

* 以上で、デザインパターンを実行するための環境準備が整いました。  
お好みのデザインパターンの作成を、お試しください。  

## 参考URL
https://laboradian.com/multi-instances-from-distro-on-wsl2/  
https://bytexd.com/how-to-install-multiple-instances-of-wsl/  
https://goodbyegangster.hatenablog.com/entry/2022/10/25/015309  
https://github.com/microsoft/WSL/issues/3974  
https://developer.hashicorp.com/terraform/downloads  
https://docs.usacloud.jp/usacloud/  
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  
https://direnv.net/  
https://manual.sakura.ad.jp/cloud/objectstorage/api.html  


