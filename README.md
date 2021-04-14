A fork of https://github.com/k3s-io/k3s-ansible

# Usage

## Deploy a cluster
```
ansible-playbook site.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```

`ecr-credential-helper` doesn't work with k3s, as a workaround an authorization token is injected into the cluster as a k8s secret. This is done by running the `post_install_scripts/ecr.sh` script. Possibly a cron job is needed (to be investigated).

Fetch the kubeconfig
```
scp -i ~/.ssh/fidexx/office.rsa -r prime@zprime-09.hftex:~/.kube/config ~/.kube/k3s_config
```

Set kubeconfig in order to use `kubectl` and `k9s`
```
export KUBECONFIG=~/.kube/k3s_config
```

Cluster is deployed without ingress controller (`traefik` by default), so we need to install NGINX.
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx
```

## Tear down a cluster
```
ansible-playbook reset.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```
