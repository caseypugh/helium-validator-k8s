#!/bin/bash
swarm_key_path=/etc/keys/$(hostname)-swarm-key
volume_swarm_key_path=/var/data/miner/swarm_key

if test -f "$swarm_key_path"; then
  echo "swarm_key exists" >> init.log
  echo "backing up volume swarm key" >> init.log
  cp $volume_swarm_key_path swarm_key_bak

  echo "moving $swarm_key_path to $volume_swarm_key_path" >> init.log
  
  cp $swarm_key_path $volume_swarm_key_path 
else
  echo "$swarm_key_path not found" >> init.log
fi

# /bin/bash
# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes
while true; do sleep 30; done;