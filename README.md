# Helium Validators on Kubernetes (k8s)

This is a DigitalOcean-specific [Kubernetes (k8s)](https://kubernetes.io/) setup for running a cluster of [Helium validators](https://www.helium.com/stake)

Some modifications are necessary to run on other Kubernetes hosts

Development is still early and pull requests are welcome

# Setup on your computer

- Install `brew install kubectl` (or [Linux/Windows](https://kubernetes.io/docs/tasks/tools/))
- Install doctl: `brew install doctl` (or [Linux/Windows](https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/))
- Create a [new API token](https://cloud.digitalocean.com/account/api/tokens/new) for yourself on Digital Ocean
- Init doctl & kubernetes cluster access on your computer

In the DO web interface, create a new Kubernetes cluster i.e. 'helium-cluster'

Then use the `doctl` tool to download that cluster's config file locally, for use with `kubectl`:

```sh
doctl auth init --context helium
Enter your access token: <API TOKEN HERE>

# now switch to the 'helium-cluster' context
doctl auth switch --context helium

# Download cluster's config file with doctl
doctl kubernetes cluster kubeconfig save helium-cluster
```

# Cluster Setup

## Setup Automatic Updates

In order for [automatic miner updates](https://github.com/caseypugh/helium-validator/blob/main/.github/workflows/update-validator.yml) to work, you need to give set the `DIGITALOCEAN_ACCESS_TOKEN` in [GitHub Secrets](https://github.com/caseypugh/helium-validator/settings/secrets/actions) so the action can run.

You can manually trigger an update by visiting the [Validator Updater](https://github.com/caseypugh/helium-validator/actions/workflows/update-validator.yml) and then click `Run workflow`.

(TODO, move this to a k8s job)

## Setup Dynamic Ports

[Install dynamic host ports](https://github.com/0blu/dynamic-hostports-k8s) so that each miner can have a unique port assigned to each pod

```sh
kubectl apply -f https://raw.githubusercontent.com/0blu/dynamic-hostports-k8s/master/deploy.yaml
```

## Apply the validator config

Then, lastly, setup the actual validator cluster:

```sh
kubectl apply -f k8s/validator.yml
# or alternately,
scripts/deploy
```

You're all set! Try running `kubectl get pods` to see if everything is working. You should see something like:

```sh
NAME          READY   STATUS    RESTARTS   AGE
validator-0   2/2     Running   0          16h
```

To watch what is going on in the cluster:

```sh
kubectl get events --all-namespaces --watch
```

To fetch logs from one of the validators, to see what's going on:

```sh
kubectl logs validator-0 validator
```

# Adding another validator

- Edit `k8s/validator.yml` and increment `spec.replicas`
- Run `scripts/deploy` to launch the new validator
- Run `kubectl get pods -w` to monitor the new pod and verify it launched.

## Managing swarm keys

A validator will generate a swarm_key for itself when it is first created. If you'd like to download those keys, run:

```sh
scripts/swarm-keys sync
```

You can also store a base64-encoded swarm_key in a password manager like 1Password if you want: `cat swarm_key | base64`

## Upload swarm_key to validator

To copy a local swarm_key file to a particular validator, run:

```sh
scripts/swarm-keys swap $replica_id $path_to_swarm_key

# sample
# scripts/swarm-keys swap 1 ~/swarm_key
```

This will update the keys and restart the specified pod.


# Optional - k8s web dashboard

DigitalOcean runs the web dashboard for you, but if you're running locally or on another host that doesn't have it, run:

```sh
scripts/setup-dashboard
```

# Optional - kube-prometheus-stack (monitoring)

And if you want to wire up prometheus/grafana/alertmanager using the `kube-prometheus-stack` helm chart, in
a manner similar to DigitalOcean:

```sh
scripts/setup-monitoring install
```

You can also upgrade an existing kube-prometheus-stack install with this script:

```
scripts/setup-monitoring upgrade
```

# Monitoring & alerts (Grafana)

See [Kubernetes Monitoring Stack](https://marketplace.digitalocean.com/apps/kubernetes-monitoring-stack) details on how to access Grafana. But tl;dr:

```sh
kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack
```
Grafana instance will now be available at <http://localhost:8080>.
