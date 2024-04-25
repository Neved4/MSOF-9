#!/bin/sh
set -Cefu

usage() {
	readonly exe_name="${0##*/}"

	printf '%s\n' "usage: $exe_name <regex> <path>"
	exit 1
} >&2

has() {
	cmd="${1:?has: cmd not set}"

	command -v "$cmd" >/dev/null
}

err_msg() {
	msg="${1:?}"

	printf "${red}error:${reset} %s\n" "$msg"
	exit 1
} >&2

main() {
	[ $# -ne 2 ] && usage

	regex="$1"
	 file="$2"
	reset='\033[0m'
	  red='\033[31m'

	has rga || err_msg 'command not found'

	rga "$regex" "$file" |
		awk '{ gsub(/\./,"", $NF); print $NF }'
}

main "$@"
