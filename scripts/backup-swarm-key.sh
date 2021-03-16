#!/bin/bash
pod=$1
container=$2

miner_name=$(kubectl exec -it $pod -- sh -c "miner info name")

mkdir -p keys
mkdir -p keys/$miner_name

kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key
# kubectl cp --container=$container $pod:/var/data/miner/swarm_key ./swarm_key 