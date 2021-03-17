#!/bin/bash

container_name=monitor
pod_name=validator
pod_replica=$2
CMD=$1

if [[ $CMD == "build" ]]; then
  docker build -t cpucpu/validator-monitor .
  docker run -it --rm cpucpu/validator-monitor
fi

if [[ $CMD == "update" ]]; then
  docker build -t cpucpu/validator-monitor .
  # docker image tag validator-monitor:latest cpucpu/validator-monitor:latest
  docker image push cpucpu/validator-monitor:latest

  # Tell Pods to update the image
  scripts/deploy.sh
fi

if [[ $CMD == "logs" ]]; then
  kubectl logs "$pod_name"-$pod_replica -c $container_name
fi

if [[ $CMD == "sh" ]]; then
  kubectl exec -it "$pod_name"-$pod_replica -c $container_name -- /bin/sh
fi