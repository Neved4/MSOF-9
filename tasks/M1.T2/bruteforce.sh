#!/bin/sh
set -Cefu

usage() {
	readonly progname="${0##*/}"

	printf '%s\n' "usage: $progname <hashes.txt> <dict.txt>"
	exit 1
} >&2

err_msg() {
	msg="${1:?}"

	printf "${red}error:${reset} %s\n" "$msg"
	exit 1
} >&2

has() {
	cmd="${1:?has: cmd not set}"

	command -v "$cmd" >/dev/null
}

check_files() {
	for i in "$@"
	do
		[ -e "$i" ] || err_msg "$i: No such file or directory"
		[ -d "$i" ] && err_msg "$i: Is a directory."
		[ -r "$i" ] || err_msg "$i: Permission denied."
	done
}

check_sha256() {
	str="${1:?check_sha256: str not set}" perl=true

	{ has sha2      && hash=$(printf '%s' "$str" | sha2 -256 || true) ;} ||
	{ has sha256sum && hash=$(printf '%s' "$str" | sha256sum)         ;} ||
	{ has openssl   && hash=$(printf '%s' "$str" | openssl sha256)    ;} ||
	{ has libressl  && hash=$(printf '%s' "$str" | libressl sha256)   ;} ||
	{ has shasum    && hash=$(printf '%s' "$str" | shasum -a 256)     ;}

	if has sha2 || has libressl || has openssl
	then
		trim="${hash##* }" perl=false
	elif has sha256sum || has shasum
	then
		trim="${hash%% *}" perl=false
	fi

	if ! $perl
	then
		printf '%s' "$trim"
		return 0
	fi

	if has perl
	then
		printf '%s' "$str" |
			perl -MDigest::SHA=sha256_hex -e 'print sha256_hex(join("", <>))'
		return 0
	fi
}

find_hash() {
	file="${1:?find_hash: file not set}"
	hash="${2:?find_hash: hash not set}"

	while IFS= read -r line
	do
		if [ "$hash" = "$line" ]
		then
			printf "${green}%s${reset} : ${red}%s${reset}\n" \
				"$hash" "$word"

			break
		fi
	done < "$file"
}

find_word() {
	hashes="${1:?find_word: hashes not set}"
	  dict="${2:?find_word: dict not set}"

	while IFS= read -r word
	do
		hash=$(check_sha256 "$word")

		find_hash "$hashes" "$hash"
	done < "$dict"
}

main() {
	[ $# -ne 2 ] && usage

	hashes="$1"
	  dict="$2"
	 reset='\033[0m'
	   red='\033[31m'
	 green='\033[32m'
	  cyan='\033[36m'

	printf '\n%24s' ''
	printf "%b\n\n" "${cyan}==[ ${progname} ]==${reset}"

	check_files "$hashes" "$dict"
	find_word "$hashes" "$dict"
}

main "$@"
