# Environment Setup

- Install `brew install kubectl` (or [Linux/Windows](https://kubernetes.io/docs/tasks/tools/))
- Install kubeseal: `brew install kubeseal` (or [Linux](https://github.com/bitnami-labs/sealed-secrets/releases/tag/v0.15.0))
- Install doctl: `brew install doctl` (or [Linux/Windows](https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/))
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

You're all set! Try running `kubectl get pods` to see if everything is working. You should see something like:

```sh
NAME          READY   STATUS    RESTARTS   AGE
validator-0   2/2     Running   0          16h
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

Afterward you'll need to update `sealed-keys.yml` (TODO) and then publish the updates with `./scripts/swarm-keys update`

### Automatic updates

In order for [automatic miner updates](https://github.com/caseypugh/helium-validator/blob/main/.github/workflows/update-validator.yml) to work, you need to give set the `DIGITALOCEAN_ACCESS_TOKEN` in [Github Secrets](https://github.com/caseypugh/helium-validator/settings/secrets/actions) so the action can run.

You can manually trigger an update by visiting the [Validator Updater](https://github.com/caseypugh/helium-validator/actions/workflows/update-validator.yml) and then click `Run workflow`.

(TODO, move this to a k8s job)

### Dynamic Ports

[Install dynamic host ports](https://github.com/0blu/dynamic-hostports-k8s) so that each miner can have a unique port assigned to each pod

```sh
kubectl apply -f https://raw.githubusercontent.com/0blu/dynamic-hostports-k8s/master/deploy.yaml
```

# Adding a new validator

- Edit `k8s/validator.yml` and increment `spec.replicas`
- Run `scripts/deploy` to launch the new validator
- Run `kubectl get pods -w` to monitor the new pod and verify it launched.

## Managing swarm keys

Once the validator is running, make sure to download the swarm key: `scripts/swarm-keys sync`.

This will place the key into `keys/$miner_name/swarm_key` and will also encrypt that key into `sealed-keys.yml`. Make sure the yml file gets committed.

Also store the swarm_key in 1password if you want via `cat swarm_key | base64`

### Swapping out a swarm key

If you want to update a swarm key, then run:

```sh
scripts/swarm-keys swap $replica_id $path_to_swarm_key

# sample
# scripts/swarm-keys swap 1 ~/swarm_key
```

This will automatically update the keys, update `sealed-keys.yml`, and restart the specified pod.

# Monitoring

See [Kubernetes Monitoring Stack](https://marketplace.digitalocean.com/apps/kubernetes-monitoring-stack) details on how to access Grafana. But tl;dr:

```sh
kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack
```

Grafana instance will now be available at <http://localhost:8080>.
