#!/bin/bash

CMD=$1
QUAY_URL='https://quay.io/api/v1/repository/team-helium/validator/tag/?limit=20&page=1&onlyActiveTags=true'
ARCH=amd
POD_NAME=validator

if [[ $CMD == "update" ]]; then
  
  miner_quay=$(curl -s "$QUAY_URL" --write-out '\nHTTP_Response:%{http_code}')
  miner_response=$(echo "$miner_quay" | grep "HTTP_Response" | cut -d":" -f2)
  

  if [[ $miner_response -ne 200 ]]; then
    echo "Bad Response from Server"
    exit 0
  fi

  miner_latest_name=$(echo "$miner_quay" | grep -v HTTP_Response | jq -c --arg ARCH "$ARCH" '[ .tags[] | select( .name | contains($ARCH)and contains("_val")) ][0].name' | cut -d'"' -f2)
  miner_latest_version=$(echo $miner_latest_name | egrep -o "[0-9]+.[0-9]+.[0-9]+" | xargs)
  container_miner_version=$(kubectl exec -it $POD_NAME-0 -c validator -- /bin/sh -c "miner versions" | egrep -o "[0-9]+.[0-9]+.[0-9]+" | xargs)

  # echo $MINER_VERSION
  # echo $miner_quay
  # echo $miner_response
  # echo $miner_latest

  if [ -z "$container_miner_version" ]; then
    echo "Validator is not up right now. Try again later"
    exit 0
  fi

  if [[ $miner_latest_version == $container_miner_version ]]; then
    echo "Already at latest version: $container_miner_version"
  else
    echo "Out of date!"
    echo "Latest version: $miner_latest_version"
    echo "Container version: $container_miner_version"

    scripts/deploy.sh
  fi
fi

if [[ $CMD == "info" ]]; then
  validator_count=$(kubectl get pods | grep -c "validator")
  for ((i = 0 ; i < $validator_count ; i++)); do
    pod="validator-$i"

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

if [[ $CMD == "bash" ]]; then
  pod_id=$2
  kubectl exec -it validator-$pod_id -c validator -- /bin/sh
fi