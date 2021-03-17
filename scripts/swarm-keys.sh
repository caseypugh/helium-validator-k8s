#!/bin/bash

CMD=$1
KEY_NAME=swarm-keys
SEALED_KEYS_PATH=k8s/sealed-keys.yml

if [[ $CMD == "sync" ]]; then
  echo; echo "Downloading swarm_keys from cluster..."

  kubectl get pods | egrep -o "helium-validator-[0-9]" | while read -r pod; do 
    miner_name=$(kubectl exec -it $pod -c validator -- sh -c "miner info name" | xargs)
    address=$(kubectl exec -it $pod -c validator -- sh -c "miner peer addr")
    address=$(echo $address | sed 's/\/p2p\///')
    
    mkdir -p keys
    mkdir -p keys/$miner_name

    kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key -c validator

    echo "Pod: $pod"
    echo "Name: $miner_name"
    echo "Address: $address"

    echo; echo "Adding $miner_name's swarm_key to $SEALED_KEYS_PATH"
    cat keys/$miner_name/swarm_key | kubectl create secret generic $KEY_NAME --dry-run=client --from-file=$pod-swarm-key=/dev/stdin -o yaml \
      | kubeseal --merge-into $SEALED_KEYS_PATH --format yaml
    echo "Make sure you backup the keys/$miner_name/swarm_key in 1password or place of choice."
  done
fi

if [[ $CMD == "update" ]]; then
  # echo "Encrypting $KEYS_PATH"
  # kubeseal <$KEYS_PATH >$SEALED_KEYS_PATH --format yaml

  echo "Uploading $SEALED_KEYS_PATH to the cluster"
  kubectl create -f $SEALED_KEYS_PATH
fi

# kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key
# kubectl cp --container=$container $pod:/var/data/miner/swarm_key ./swarm_key 
