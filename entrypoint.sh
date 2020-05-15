#!/usr/bin/env bash

set -e

PROFILE=$PROFILE

if [[ $PROFILE == "local" ]]; then
	EXTERNAL_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
	INTERNAL_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
else
	EXTERNAL_IP=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)
	INTERNAL_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
fi

echo "[ENTRYPOINT] - Got private IP: ${INTERNAL_IP}"
echo "[ENTRYPOINT] - Got public IP: ${EXTERNAL_IP}"

pushd /usr/local/freeswitch/conf
	echo "[ENTRYPOINT] - Updating FreeSWITCH vars.xml"
	sed -i "s/<EXTERNAL_IP>/$EXTERNAL_IP/g w /dev/stdout" vars.xml
popd

echo "[ENTRYPOINT] - Starting FreeSWITCH"

cat /usr/local/freeswitch/conf/vars.xml ||:

stdbuf -i0 -o0 -e0 /usr/local/bin/freeswitch -nc
