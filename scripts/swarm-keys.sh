#!/bin/bash

CMD=$1
KEYS_TMPL=k8s/keys.template.yml
KEYS_PATH=k8s/keys.yml # should be gitignored
SEALED_KEYS_PATH=k8s/sealed-keys.yml

if [[ $CMD == "sync" ]]; then
  echo; echo "Downloading swarm_keys from cluster..."

  if [ ! -f "$KEYS_PATH" ]; then
    echo "Generating $KEYS_PATH"
    cat $KEYS_TMPL > $KEYS_PATH
  fi

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

    # echo "  $pod-name: $(echo $miner_name | base64)" >> $KEYS_PATH
    # echo "  $pod-address: $(echo $address | base64)" >> $KEYS_PATH
    echo; echo "Adding swarm_key to keys.yml"
    echo "  $pod-swarm-key: $(cat keys/$miner_name/swarm_key | base64)" >> $KEYS_PATH
    echo "Make sure you backup the keys/$miner_name/swarm_key in 1password or place of choice."
  done
fi

if [[ $CMD == "update" ]]; then
  echo "Encrypting $KEYS_PATH"
  kubeseal <$KEYS_PATH >$SEALED_KEYS_PATH --format yaml

  echo "Uploading $SEALED_KEYS_PATH to the cluster"
  kubectl create -f $SEALED_KEYS_PATH
fi

# kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key
# kubectl cp --container=$container $pod:/var/data/miner/swarm_key ./swarm_key 