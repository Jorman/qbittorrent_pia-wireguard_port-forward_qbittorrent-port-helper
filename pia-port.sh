#!/bin/bash

trap 'exit 0' SIGTERM

sleep 10

############ CONFIGURATION ############
oldport=0
port=0
#######################################
qbt_host="http://localhost" # qbittorrent machine?
#qbt_host=$(getent hosts `hostname` | awk '{print $1}')
#qbt_username="admin" # Username for qbittorrent remote machine
#qbt_password="adminadmin" # Password for qbittorrent remote machine
#qbt_port="8081" # Port for qbittorrent webui
############ CONFIGURATION ############

############ FUNCTIONS ############
get_cookie () { # get the cookie
	echo "Getting cookie ..."
	qbt_cookie=$(curl --silent --fail --show-error \
		--header "Referer: ${qbt_host}:${qbt_port}" \
		--cookie-jar - \
		--request GET "${qbt_host}:${qbt_port}/api/v2/auth/login?username=${qbt_username}&password=${qbt_password}")
	echo "done"
}
############ FUNCTIONS ############

while true
do
	[ -r "/pia-shared/port.dat" ] && port=$(cat /pia-shared/port.dat)

	if [ $oldport -ne $port ]; then

		get_cookie

		echo "$qbt_cookie" | curl --silent --fail --show-error \
			--cookie - \
			--request POST "${qbt_host}:${qbt_port}/api/v2/app/setPreferences" \
			--data 'json={"listen_port": "'"$port"'"}'
		sleep 1

		oldport=$port
	fi
	sleep 30 &
	wait $!
done