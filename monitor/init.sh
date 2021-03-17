#!/bin/bash
echo "hostname=$(hostname)";
swarm_key_path=/etc/keys/$(hostname)-swarm-key
# volume_swarm_key_path=/var/data/test

if test -f "$swarm_key_path"; then
  echo "swarm_key exists" >> init.log
  key64=$(cat  | base64)
  echo $key64 > logtime2
fi

# /bin/bash
# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes
while true; do sleep 30; done;