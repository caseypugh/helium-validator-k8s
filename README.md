### Setup

- Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install kubeseal: `brew install kubeseal`
- Install doctl: `brew install doctl`
- Download kubeconfig with doctl
```
doctl kubernetes cluster kubeconfig save helium-cluster
```

### Development
- Modify `validator.yml`. Use `scripts/deploy.sh` to deploy changes to the Pod.
- When adding another validator, increase `spec.replicas` by one and deploy. Afterward, run `scripts/update-keys.sh` to update the swarm keys. 