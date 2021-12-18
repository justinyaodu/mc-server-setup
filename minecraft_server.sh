#!/bin/bash

set -euo pipefail

config_file='/etc/minecraft_server'

log() {
	echo "${0}: ${*}" >&2
}

usage() {
	cat << EOF
Usage: $(basename "${0}") [OPTIONS...] [MC_ARGS...]
Start a Minecraft server.

Options:
  -s, --server DIR  start the server in this directory
  -t, --tmux        run the server in a tmux session
  -d, --detach      detach the tmux session
      --debug       run the script with set -x
  -h, --help        show this help message and exit
EOF
}

main() {
	local server=''
	local use_tmux=0
	local detach=0
	while (( $# )); do
		case "${1}" in
			-s|--server)
				if (( $# < 2 )); then
					log "option ${1} requires an argument"
					return 2
				fi
				server="${2}"
				shift
				;;
			-t|--tmux)
				use_tmux=1
				;;
			-d|--detach)
				detach=1
				;;
			--debug)
				set -x
				;;
			-h|--help)
				usage
				return
				;;
			*)
				break
				;;
		esac
		shift
	done

	source "${config_file}"
	cd "${servers_dir}"

	server="${server:-$default_server}"
	if [ ! "${server}" ]; then
		log "no server specified (use the -s option or configure a" \
				"default server in ${config_file})"
		return 1
	fi

	cd "${server}"
	[ -f "${server_config}" ] && source "${server_config}"

	local server_cmd=(java "${jvm_args[@]}" -jar "${server_jar}"
			"${mc_args[@]}" "${@}")
	
	if (( use_tmux )); then
		if tmux has-session -t "=${session_name}" &> /dev/null; then
			log "already running in tmux (attach with:" \
					"tmux attach -t ${session_name})"
			return 3
		fi

		local tmux_args=(new-session -s "${session_name}" -c "${PWD}")
		(( detach )) && tmux_args+=(-d)
		exec tmux "${tmux_args[@]}" "${server_cmd[@]}"
	else
		exec "${server_cmd[@]}"
	fi
}

main "${@}"
