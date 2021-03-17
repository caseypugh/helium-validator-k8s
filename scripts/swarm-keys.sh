#!/bin/bash

CMD=$1
KEY_NAME=swarm-keys
SEALED_KEYS_PATH=k8s/sealed-keys.yml

add_key_from_file()
{
  key=$1
  file=$2

  if test -f $SEALED_KEYS_PATH; then
    kubectl create secret generic $KEY_NAME --dry-run=client --from-file=$key=$file -o yaml \
      | kubeseal --merge-into $SEALED_KEYS_PATH --format yaml --cert cert.pem
  else
    kubectl create secret generic $KEY_NAME --dry-run=client --from-file=$key=$file -o yaml \
      | kubeseal > $SEALED_KEYS_PATH --format yaml --cert cert.pem
  fi
}

if [[ $CMD == "sync" ]]; then
  echo; echo "Downloading swarm_keys from cluster..."

  validator_count=$(kubectl get pods | grep -c "helium-validator")
  for ((i = 0 ; i < $validator_count ; i++)); do
    pod="helium-validator-$i"
    echo; echo "Pod: $pod"

    miner_name=$(kubectl exec -it $pod -c validator -- sh -c "miner info name" | egrep -o "[a-z]+-[a-z]+-[a-z]+" | xargs)
    address=$(kubectl exec -it $pod -c validator -- sh -c "miner peer addr")
    address=$(echo $address | sed 's/\/p2p\///')
    
    echo "Miner Name: $miner_name"
    echo "Miner Address: $address"

    mkdir -p keys
    mkdir -p keys/$miner_name

    kubectl cp $pod:/var/data/miner/swarm_key keys/$miner_name/swarm_key -c validator

    echo; echo "Adding $miner_name swarm_key to $SEALED_KEYS_PATH"

    add_key_from_file $pod-swarm-key keys/$miner_name/swarm_key
    # add_key $pod-miner-name $miner_name
    # add_key $pod-miner-address $address
    
    echo "Make sure you backup keys/$miner_name/swarm_key in 1password or place of choice."
  done
fi

if [[ $CMD == "swap" ]]; then
  pod_name=$2
  swarm_key_path=$3

  add_key_from_file $pod_name-swarm-key $swarm_key_path
  # scripts/swarm-keys.sh update
fi

if [[ $CMD == "update" ]]; then
  echo "Uploading $SEALED_KEYS_PATH to the cluster"
  kubectl delete -f $SEALED_KEYS_PATH
  kubectl create -f $SEALED_KEYS_PATH

  scripts/deploy.sh
fi