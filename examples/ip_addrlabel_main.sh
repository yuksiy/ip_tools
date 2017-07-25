#!/bin/sh -e

# ==============================================================================
#   機能
#     IPv6アドレスラベルスクリプトを実行する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2011-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

### BEGIN INIT INFO
# Provides:          ip_addrlabel_main
# Required-Start:    networking
# Required-Stop:     
# Should-Start:      ifupdown_ppp
# Should-Stop:       
# X-Start-Before:    
# X-Stop-After:      
# Default-Start:     2 3 4 5
# Default-Stop:      
# X-Interactive:     
# Short-Description: IPv6 address label
# Description:       
### END INIT INFO

######################################################################
# 変数定義
######################################################################
# ユーザ変数

# システム環境 依存変数
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin

# プログラム内部変数
IP_ADDRLABEL="/usr/local/sbin/ip_addrlabel.sh"
ADDR_LABEL_LIST="/etc/gai.conf"

#DEBUG=TRUE

######################################################################
# 関数定義
######################################################################
USAGE() {
	cat <<- EOF 1>&2
		Usage:
		  ip_addrlabel_main.sh MODE
		
		  MODE : {start}
	EOF
}

######################################################################
# メインルーチン
######################################################################

# 第1引数のチェック
if [ "$1" = "" ];then
	echo "-E Missing MODE argument" 1>&2
	USAGE;exit 1
else
	# モードのチェック
	case "$1" in
	start)
		MODE="$1"
		;;
	*)
		echo "-E Invalid MODE argument" 1>&2
		USAGE;exit 1
		;;
	esac
fi

#####################
# メインループ 開始 #
#####################

# 処理開始メッセージの表示
echo "IPv6 address label script: ip_addrlabel_main.sh ${MODE}"

case "${MODE}" in
start)
	${IP_ADDRLABEL} flush -C -f inet6
	${IP_ADDRLABEL} add   -C -f inet6 ${ADDR_LABEL_LIST}
	;;
esac

exit 0

