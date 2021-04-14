A fork of https://github.com/k3s-io/k3s-ansible

## Deploy a cluster
```
ansible-playbook site.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```

`ecr-credential-helper` doesn't work with k3s, as a workaround an authorization token is injected into the cluster as a k8s secret. This is done by running the `post_install_scripts/ecr.sh` script. Possibly a cron job is needed (to be investigated).

```
cd post_install_scripts
NAMESPACE=<namespace> ./ecr.sh
```

Cluster is deployed without an ingress controller (`traefik` by default), so we need to install NGINX (info on setting up `kubectl` in the next section)
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx
```

### Setting up kubectl
Fetch the kubeconfig from master node, example for current setup:
```
scp -i ~/.ssh/fidexx/office.rsa -r prime@zprime-09.hftex:~/.kube/config ~/.kube/k3s_config
```

Set kubeconfig in order to use `kubectl` and `k9s`
```
export KUBECONFIG=~/.kube/k3s_config
```

## Tear down a cluster
```
ansible-playbook reset.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```

Sporadically firewall can cause issues when redeploying the cluster (`coredns` pod is in failed state), to solve this flush the `iptables` and restart docker in order to populate the rules again.

```
sudo iptables -F
sudo systemctl restart docker
```
