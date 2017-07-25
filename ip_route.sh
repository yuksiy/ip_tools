#!/bin/sh

# ==============================================================================
#   機能
#     ルートリストに従ってIPルーティングテーブルを操作する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2006-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 関数定義
######################################################################
USAGE() {
	cat <<- EOF 1>&2
		Usage:
		    ip_route.sh ACTION [OPTIONS ...] [ARGUMENTS ...]
		
		ACTIONS:
		    add  [OPTIONS ...] IP_ROUTE_LIST IFACE [GW]
		    del  [OPTIONS ...] IP_ROUTE_LIST IFACE [GW]
		    list [OPTIONS ...]
		
		ARGUMENTS:
		    IP_ROUTE_LIST : Specify the IP route list.
		    IFACE         : Specify the interface name to manipulate the IP routing table.
		    GW            : Specify the address of the nexthop router.
		
		OPTIONS:
		    -n (no-play)
		       Print the commands that would be executed, but do not execute them.
		       (Available with: add, del, list)
		    -v (verbose)
		       Verbose output.
		       (Available with: add, del, list)
		    -C (colored)
		       Colored output.
		       (Available with: add, del)
		    -f FAMILY  : {inet|inet6}
		       Default is ${FAMILY}.
		       (Available with: add, del, list)
		    --help
		       Display this help and exit.
	EOF
}

######################################################################
# 変数定義
######################################################################
# ユーザ変数

# システム環境 依存変数

# プログラム内部変数
OBJECT="route"

FLAG_OPT_NO_PLAY=FALSE
FLAG_OPT_VERBOSE=FALSE
FAMILY="inet"

COLOR_ECHO="color_echo.sh"
COLOR_INFO="light_blue"
COLOR_ERR="light_red"

ECHO_INFO="echo"
ECHO_ERR="${ECHO_INFO}"

######################################################################
# メインルーチン
######################################################################

# ACTIONのチェック
if [ "$1" = "" ];then
	echo "-E Missing ACTION" 1>&2
	USAGE;exit 1
else
	case "$1" in
	add|del|list)
		ACTION="$1"
		;;
	*)
		echo "-E Invalid ACTION -- \"$1\"" 1>&2
		USAGE;exit 1
		;;
	esac
fi

# ACTIONをシフト
shift 1

# オプションのチェック
CMD_ARG="`getopt -o nvCf: -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	-n)	FLAG_OPT_NO_PLAY=TRUE ; shift 1;;
	-v)	FLAG_OPT_VERBOSE=TRUE ; shift 1;;
	-C)
		ECHO_INFO="${COLOR_ECHO} -F ${COLOR_INFO}"
		ECHO_ERR="${COLOR_ECHO} -F ${COLOR_ERR}"
		shift 1
		;;
	-f)
		case "$2" in
		inet|inet6)	FAMILY="$2" ; shift 2;;
		*)
			echo "-E Argument to \"${opt}\" is invalid -- \"$2\"" 1>&2
			USAGE;exit 1
			;;
		esac
		;;
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

# 引数のチェック
case ${ACTION} in
add|del)
	# 第1引数のチェック
	if [ "$1" = "" ];then
		echo "-E Missing IP_ROUTE_LIST argument" 1>&2
		USAGE;exit 1
	else
		IP_ROUTE_LIST="$1"
		# ルートリストのチェック
		if [ ! -f "${IP_ROUTE_LIST}" ];then
			echo "-E IP_ROUTE_LIST not a file -- \"${IP_ROUTE_LIST}\"" 1>&2
			USAGE;exit 1
		fi
	fi
	# 第2引数のチェック
	if [ "$2" = "" ];then
		echo "-E Missing IFACE argument" 1>&2
		USAGE;exit 1
	else
		IFACE="$2"
		# インターフェイス名のチェック
		ifconfig "${IFACE}" >/dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "-E IFACE not an interface -- \"${IFACE}\"" 1>&2
			USAGE;exit 1
		fi
	fi
	# 第3引数のチェック
	if [ ! "$3" = "" ];then
		GW="$3"
	fi
	;;
esac

# 変数定義(引数のチェック後)
IP_ROUTE_OPTIONS="-f ${FAMILY}"
case ${FAMILY} in
inet)	ADDR_DESC="IPv4";;
inet6)	ADDR_DESC="IPv6";;
esac

# 処理開始メッセージの表示
case ${ACTION} in
add|del)
	echo -n " ${ADDR_DESC} ${OBJECT} ${ACTION} "
	;;
esac

# メインループ
case ${ACTION} in
add|del)
	awk \
		-v FLAG_OPT_NO_PLAY="${FLAG_OPT_NO_PLAY}" \
		-v FLAG_OPT_VERBOSE="${FLAG_OPT_VERBOSE}" \
		-v OBJECT="${OBJECT}" \
		-v ACTION="${ACTION}" \
		-v IFACE="${IFACE}" \
		-v GW="${GW}" \
		-v IP_ROUTE_OPTIONS="${IP_ROUTE_OPTIONS}" \
	'{
		# コメントまたは空行でない場合
		if ($0 !~/^#/ && $0 != "") {
			# フィールド値の取得
			addr=$1
			mask=$2

			# 必須フィールドのチェック
			if (addr == "" || mask == "") {
				system(sprintf("echo 1>&2"))
				system(sprintf("echo \042-E Omitted required field at line %s -- \134\042${IP_ROUTE_LIST}\134\042\042 1>&2", NR))
				system(sprintf("echo \047%s\047 1>&2", $0))
				exit 1
			}

			# コマンドラインの構成
			cmd_line="ip"
			if (IP_ROUTE_OPTIONS  !~/^$/) cmd_line=cmd_line" "IP_ROUTE_OPTIONS
			                              cmd_line=cmd_line" "OBJECT
			if (ACTION            !~/^$/) cmd_line=cmd_line" "ACTION
			if (addr              !~/^$/) cmd_line=cmd_line" "addr
			if (mask              !~/^$/) cmd_line=cmd_line"/"mask
			if (IFACE             !~/^$/) cmd_line=cmd_line" dev "IFACE
			if (GW                !~/^$/) cmd_line=cmd_line" via "GW

			# コマンドラインの出力・実行
			if (FLAG_OPT_NO_PLAY == "FALSE") {
				if (FLAG_OPT_VERBOSE == "TRUE") {
					printf("+ %s\n", cmd_line)
				}
				rc=system(cmd_line)
				if (rc != 0) {
					exit 1
				}
			} else {
				printf("%s\n", cmd_line)
			}
		}
	}' "${IP_ROUTE_LIST}"
	if [ $? -ne 0 ];then
		${ECHO_ERR} "NG! -- Command has ended unsuccessfully."
		exit 1
	fi
	;;
list)
	# コマンドラインの構成
	cmd_line="ip ${IP_ROUTE_OPTIONS} ${OBJECT} ${ACTION}"
	# コマンドラインの出力・実行
	if [ "${FLAG_OPT_NO_PLAY}" = "FALSE" ];then
		if [ "${FLAG_OPT_VERBOSE}" = "TRUE" ];then
			printf "+ %s\n" "${cmd_line}"
		fi
		case ${ACTION} in
		list)
			eval "${cmd_line}"
			if [ $? -ne 0 ];then
				exit 1
			fi
			;;
		esac
	else
		printf "%s\n" "${cmd_line}"
	fi
	;;
esac

# 処理終了メッセージの表示
case ${ACTION} in
add|del)
	${ECHO_INFO} "OK!"
	;;
esac

exit 0

