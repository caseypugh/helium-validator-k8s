# Environment Setup

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

# Cluster Setup
This is already done but writing just in case we need to do it again.

### Secrets setup
Install [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets/releases) into the cluster
```sh
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.15.0/controller.yaml
```

And then you'll need to make sure your public cert is the same as the server's:
```
kubeseal --fetch-cert >cert.pem
```

Afterward you'll need to update `sealed-keys.yml` (TODO) and then publish the updates with `./scripts/swarm-keys.sh update` 

### Automatic updates
In order for [automatic miner updates](https://github.com/caseypugh/helium-validator/blob/main/.github/workflows/update-validator.yml) to work, you need to give set the `DIGITALOCEAN_ACCESS_TOKEN` in [Github Secrets](https://github.com/caseypugh/helium-validator/settings/secrets/actions) so the action can run.

You can manually trigger an update by visiting the [Validator Updater](https://github.com/caseypugh/helium-validator/actions/workflows/update-validator.yml) and then click `Run workflow`.

# Development
- Modify `validator.yml`. Use `scripts/deploy.sh` to deploy changes to the Pod.
- When adding another validator, increase `spec.replicas` by one and deploy. Afterward, run `scripts/swarm-keys.sh sync` to update the swarm keys. 
- TODO.... but check out `scripts` folder to see tooling.