#!/bin/bash

CMD=$1

if [[ $CMD == "info" ]]; then
  validator_count=$(kubectl get pods | grep -c "helium-validator")
  for ((i = 0 ; i < $validator_count ; i++)); do
    pod="helium-validator-$i"

    echo; echo "Pod: $pod"
    
    miner_name=$(kubectl exec -it $pod -c validator -- sh -c "miner info name" | egrep -o "[a-z]+-[a-z]+-[a-z]+" | xargs)
    address=$(kubectl exec -it $pod -c validator -- sh -c "miner peer addr")
    address=$(echo $address | sed 's/\/p2p\///')
    
    echo "Miner Name: $miner_name"
    echo "Miner Address: $address"
    echo "Validator API: https://testnet-api.helium.wtf/v1/validators/$address"

    kubectl exec -it $pod -c validator -- sh -c "miner info p2p_status && miner peer book -s"
  done
fi