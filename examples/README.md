# examples

## 「ip_addrlabel_main.sh」ファイル

Linux (Debian) にて、システムの起動時に
「ip_addrlabel.sh」を自動起動するためのサンプルファイルです。

### 自動起動設定

    # install -p ip_addrlabel_main.sh /etc/init.d/
    # insserv -v ip_addrlabel_main.sh

### 自動起動設定の戻し

    # insserv -v -r ip_addrlabel_main.sh
    # rm /etc/init.d/ip_addrlabel_main.sh
