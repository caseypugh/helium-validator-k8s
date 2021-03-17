CMD=$1

if [[ $CMD == "restart" ]]; then
  kubectl delete -f k8s/validator.yml && \
  kubectl apply -f k8s/validator.yml
else
  kubectl apply -f k8s/validator.yml
fi

kubectl get pods -w