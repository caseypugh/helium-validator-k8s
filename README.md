### Setup

- Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install kubeseal: `brew install kubeseal`
- [Download kube config](https://cloud.digitalocean.com/kubernetes/clusters/3d30c10c-e5f3-40e5-a527-1d0d5c9f7edd?i=3ff5d8) from Digital Ocean and put in `.kube/config`

### Development
- Modify `validator.yml`. Use `scripts/deploy.sh` to deploy changes to the Pod.
- When adding another validator, increase `spec.replicas` by one and deploy. Afterward, run `scripts/update-keys.sh` to update the swarm keys. 