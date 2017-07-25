# ip_tools

## 概要

iproute の補足ツール

## 使用方法

### ip_addrlabel.sh

    IPv6アドレスラベルの一覧を表示します。
    # ip_addrlabel.sh list

    アドレスラベルリストに書かれたIPv6アドレスラベルをカーネルに追加します。
    # ip_addrlabel.sh add アドレスラベルリストのファイル名

    アドレスラベルリストに書かれたIPv6アドレスラベルをカーネルから削除します。
    # ip_addrlabel.sh del アドレスラベルリストのファイル名

    全てのIPv6アドレスラベルをカーネルから削除します。
    # ip_addrlabel.sh flush

#### アドレスラベルリストの書式

glibc の設定ファイルである「/etc/gai.conf」の書式と互換性を保つことを前提としています。  
したがって、本ツールで使用するアドレスラベルリストとして、
システムで設定済みの「/etc/gai.conf」を共用することができます。

    第1カラム   第2カラム       第3カラム
    -----------------------------------------
    キーワード  プレフィックス  ラベル値

    ・「#」で始まる行はコメント行扱いされます。
    ・空行は無視されます。
    ・カラム区切り文字は「1文字以上の半角スペース」とします。
    ・キーワードフィールドの値が下記以外である行は本ツールでは無視されます。
        label

### ip_route.sh

    IPv4/IPv6用ルーティングテーブルの内容を表示します。
    # ip_route.sh list -f inet
    # ip_route.sh list -f inet6

    IPv4/IPv6用ルートリストに書かれた経路をIPv4/IPv6用ルーティングテーブルに追加します。
    # ip_route.sh add -f inet  IPv4用ルートリストのファイル名 インターフェイス名 [IPv4ゲートウェイアドレス]
    # ip_route.sh add -f inet6 IPv6用ルートリストのファイル名 インターフェイス名 [IPv6ゲートウェイアドレス]

    IPv4/IPv6用ルートリストに書かれた経路をIPv4/IPv6用ルーティングテーブルから削除します。
    # ip_route.sh del -f inet  IPv4用ルートリストのファイル名 インターフェイス名 [IPv4ゲートウェイアドレス]
    # ip_route.sh del -f inet6 IPv6用ルートリストのファイル名 インターフェイス名 [IPv6ゲートウェイアドレス]

#### ルートリストの書式

    (IPv4用)
    第1カラム                 第2カラム                   第3カラム以降
    -----------------------------------------------------------------------------
    IPv4ネットワークアドレス  サブネットマスク            備考 (無視されます)

    (IPv6用)
    第1カラム                 第2カラム                   第3カラム以降
    -----------------------------------------------------------------------------
    IPv6ネットワークアドレス  サブネットプレフィックス長  備考 (無視されます)

    ・「#」で始まる行はコメント行扱いされます。
    ・空行は無視されます。
    ・カラム区切り文字は「タブ」とします。

### その他

* 上記で紹介したツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* iproute (ipコマンド等)
* [color_tools](https://github.com/yuksiy/color_tools) (「ip_addrlabel.sh」「ip_route.sh」 にて「-C オプション」を使用する場合のみ)

## インストール

ソースからインストールする場合:

    (Linux の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/ip_tools>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/ip_tools/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2006-2017 Yukio Shiiya
