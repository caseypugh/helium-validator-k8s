## Environment Setup

- Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install kubeseal: `brew install kubeseal`
- Install doctl: `brew install doctl`
- Create a [new API token](https://cloud.digitalocean.com/account/api/tokens/new) for yourself on Digital Ocean
- Init doctl & kubernetes cluser access on your computer
```sh
doctl auth init --context loris
Enter your access token: <API TOKEN HERE>

# now switch to the loris context
doctl auth switch --context loris

# Download kubeconfig with doctl
doctl kubernetes cluster kubeconfig save helium-cluster
```

## Cluster Setup
This is already done but writing just in case we need to do it again.

Make sure the cluster has [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets/releases) installed
```sh
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.15.0/controller.yaml
```

And then you'll need to make sure your public cert is the same as the server's:
```
kubeseal --fetch-cert >cert.pem
```

Afterward you'll need to update `sealed-keys.yml` (TODO) and then publish the updates with `./scripts/swarm-keys.sh update`

## Development
- Modify `validator.yml`. Use `scripts/deploy.sh` to deploy changes to the Pod.
- When adding another validator, increase `spec.replicas` by one and deploy. Afterward, run `scripts/update-keys.sh` to update the swarm keys. 