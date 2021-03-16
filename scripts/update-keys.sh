#!/bin/bash

kubectl get pods | egrep -o "helium-validator-[0-9]" | while read -r pod; do 
  miner_name=$(kubectl exec -it $pod -- sh -c "miner info name" | xargs)
  address=$(kubectl exec -it $pod -- sh -c "miner peer addr")
  address=$(echo $address | sed 's/\/p2p\///')
  
  mkdir -p keys
  mkdir -p keys/$miner_name

  kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key

  echo "Pod: $pod"
  echo "Name: $miner_name"
  echo "Address: $address"

  echo "  $pod-name: $(echo $miner_name | base64)" >> keys.yml
  echo "  $pod-address: $(echo $address | base64)" >> keys.yml
  echo "  $pod-swarm-key: $(cat keys/$miner_name/swarm_key | base64)" >> keys.yml
done

kubeseal <keys.yml >sealed-keys.yml --format yaml

# kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key
# kubectl cp --container=$container $pod:/var/data/miner/swarm_key ./swarm_key 