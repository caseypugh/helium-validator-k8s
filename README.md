# Helium Validators on Kubernetes (k8s)

![](assets/logo.png)

This is a DigitalOcean-specific [Kubernetes (k8s)](https://kubernetes.io/) setup for running a cluster of [Helium validators](https://www.helium.com/stake). Some modifications are necessary to run on other Kubernetes hosts.

Development is still early and pull requests are welcome!

### Table of contents
- [Helium Validators on Kubernetes (k8s)](#helium-validators-on-kubernetes-k8s)
    - [Table of contents](#table-of-contents)
- [Local environment setup](#local-environment-setup)
- [Cluster setup](#cluster-setup)
  - [Deploy the validators](#deploy-the-validators)
  - [Automatic updates](#automatic-updates)
  - [Modify disk space](#modify-disk-space)
- [Validator Management](#validator-management)
  - [Check status](#check-status)
  - [Add a new validator](#add-a-new-validator)
  - [Staking validators](#staking-validators)
  - [Managing swarm keys](#managing-swarm-keys)
  - [Replace a swarm key](#replace-a-swarm-key)
- [Monitoring](#monitoring)
  - [Accessing Grafana](#accessing-grafana)
  - [Setting up the validator dashboard](#setting-up-the-validator-dashboard)
  - [Receiving Alerts](#receiving-alerts)
  - [Kubernetes dashboard (optional)](#kubernetes-dashboard-optional)
- [Troubleshooting](#troubleshooting)

# Local environment setup
All the core essentials you will need to get your environment setup:
- Install **kubectl**: 
`brew install kubectl` (or [Linux/Windows](https://kubernetes.io/docs/tasks/tools/))
- Install **doctl**: `brew install doctl` (or [Linux/Windows](https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/))
- Install **helm**: `brew install helm` (or [Linux/Windows](https://helm.sh/docs/intro/install/))
- Install **jq**: `brew install jq` or `sudo apt install jq`

# Cluster setup

Create a new [Kubernetes cluster](https://cloud.digitalocean.com/kubernetes/clusters) on DigitalOcean. (i.e. 'helium-cluster')

Once setup, use `doctl` to download that cluster's config file locally, for use with `kubectl`. Also, create a [new API token](https://cloud.digitalocean.com/account/api/tokens/new) for yourself on DigitalOcean:

```sh
doctl auth init --context helium
Enter your access token: <DIGITALOCEAN API TOKEN HERE>

# now switch to the 'helium-cluster' context
doctl auth switch --context helium

# Download cluster's config file with doctl
doctl kubernetes cluster kubeconfig save helium-cluster
```

## Deploy the validators
Before you setup the validators, create a `helium` namespace and set it as your default:
```sh
kubectl create ns helium
kubectl config set-context --current --namespace helium
```

Create your `.env` file from the sample one provided.
```sh
cp .env.sample .env
```

The main env vars you'll need to setup are:
```sh
# Default namespace context as defined earlier
NAMESPACE=helium

# Number of validators you'd like to run
TOTAL_MAINNET_VALIDATORS=2

# To get the name of your cluster run `kubectl config current-context`
MAINNET_CLUSTER=do-nyc1-helium-cluster
```

The following script will automatically deploy everything you need to run and monitor your validators. 

```sh
scripts/deploy
# This automatically deploys 
# - k8s/exporter-service.yml
# - k8s/validator.yml
# - dynamic-hostports
# - kube-prometheus-stack (Prometheus & Grafana)
```

You're all set! Try running `kubectl get pods` to see if everything is working. You should see something like:

```sh
NAME          READY   STATUS    RESTARTS   AGE
validator-0   2/2     Running   0          5m
validator-1   2/2     Running   0          5m
```

## Automatic updates

Validators will automatically update themselves whenever a new version is released. If a validator is currently in consensus, it will not update until it is out of consensus.

## Modify disk space
By default, every validator will have 20GB of space each. If the validators start to need more space, you will have to modify each of your PVCs:
```sh
# To get the name of your PVC(s)
kubectl get pvc

# <new-size> = i.e. '40Gi'
kubectl patch pvc <your-pvc-name> -p '{ "spec": { "resources": { "requests": { "storage": "<new-size>" }}}}'
```


# Validator Management
If you look inside the `/scripts` you'll see there are a bunch of helper scripts written to make validator management easier. Below are some of the most common uses: 

## Check status

Run this to see details on all your validators:

```sh
scripts/validator info

# Alternatively, you can specify the replica index to show a specific validator
scripts/validator info $replica_id
```

And then you should see something like this:
```
Pod: validator-1
Name: cool-hotspot-name
Address: 1YJSgoGPDpqC339KfysdfsdfVc4sG7JBJEUci1i1dKG
Version: 0.1.82
Validator API: https://api.helium.io/v1/validators/1YJSgoGPDpqC339KfysdfsdfVc4sG7JBJEUci1i1dKG
Not currently in consensus group
+---------+-------+
|  name   |result |
+---------+-------+
|connected|  no   |
|dialable |  yes  |
|nat_type |unknown|
| height  | 15145 |
+---------+-------+
```

## Add a new validator

- Edit `TOTAL_MAINNET_VALIDATORS` in your `.env` 
- Run `scripts/deploy` and the new validator(s) will automatically deploy.
- Run `kubectl get pods -w` to monitor the new pod and verify it launched.


## Staking validators
Please refer to [Helium's guide](https://docs.helium.com/mine-hnt/validators/testnet/wallet/) on staking a validator. To get a validator's address, use the `scripts/validator info` command as described above.

## Managing swarm keys

A validator will generate a `swarm_key` for itself when it is first created. If you'd like to download those keys, run:

```sh
scripts/swarm-keys sync
# keys will be saved to disk in the /keys/$hotspot-name folder
```

If you have [1Password CLI](https://1password.com/downloads/command-line/) installed, this script can automatically save all the swarm_keys to your vault! Get your vault's `UUID` and set the `OP_VAULT_UUID` in your `.env` file. Here's a quick way to fetch a UUID for your Personal vault:
```sh
op list vaults | jq -r '.[] | select(.name == "Private") | .uuid'
```

## Replace a swarm key

To copy a local swarm_key file to a particular validator replica, run:

```sh
scripts/swarm-keys replace $replica_id $path_to_swarm_key

# For example
scripts/swarm-keys replace 1 ~/path/to/swarm_key
```

And if you have the 1Password CLI setup (as described earlier), then you can use the name of your validator instead:
```sh
scripts/swarm-keys replace $replica_id $animal_hotspot_name
```

This will update the swarm_key and restart the specified pod replica.

# Monitoring 


## Accessing Grafana
Grafana and prometheus should already be running thanks to the deploy script. Now you can setup a proxy to your Grafana dashboard using:
```sh
scripts/dashboard/monitor
```

If successful, you should see the following:
```sh
Visit =>
Grafana: http://localhost:3000 
Prometheus query tool: http://localhost:9090
Alertmanager: http://localhost:9093
```

Visit [http://localhost:3000](http://localhost:3000) to see your Grafana dashboard.

## Setting up the validator dashboard
![](assets/dashboard.png)

Now that Grafana is setup and you have port forwarding running, let's get your Helium validator dashboard setup. Run this command:
```
scripts/dashboard/sync
```

## Receiving Alerts
There are already a bunch of alerts setup in this dashboard, but if you'd like to receive push notifications (Discord, Slack, etc) whenever there are alerts, create a new [notification channel](http://localhost:3000/alerting/notifications). 

Once created, set the `GRAFANA_NOTIFICATION_CHANNEL` env var to the `id` of your notification (you can find it in the URL). Then just rerun `scripts/dashboard/sync` and it will automatically update all the panel alerts to the notification channel.

## Kubernetes dashboard (optional)

DigitalOcean has the Kubernetes Dashboard setup for you already, but if you're running locally or on another host that doesn't have it, you can run:

```sh
scripts/setup-k8s-dashboard
```

_Note: I don't really use this dashboard much and primarily just use [k9s](https://github.com/derailed/k9s)_

# Troubleshooting
Some very helpful tools to make your Kubernetes life easier
- [k9s](https://github.com/derailed/k9s) - K9s provides a terminal UI to interact with your Kubernetes clusters.
- [BotKube](https://www.botkube.io/) - BotKube is a messaging bot for monitoring and debugging Kubernetes clusters.

More coming soon...