A fork of https://github.com/k3s-io/k3s-ansible

## Deploy a cluster
```
ansible-playbook site.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```

Run post-install setup script
```
./post_install/setup.sh
```

Script will fetch the `.kubeconfig`, set env var in order to use `kubectl` and `k9s`
```
export KUBECONFIG=~/.kube/k3s_config
```

## Add a new node

First obtain the node token by running the following command on master node:
```
prime@zprime-09:~$ sudo cat /var/lib/rancher/k3s/server/node-token
<token>
```

```
ansible-playbook site.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass --limit <node-to-add> -e "token_override='<token>'"
```

## Remove a node

```
ansible-playbook reset.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass --limit <node-to-remove>
```

After this manually delete the node from cluster using `kubectl` or `k9s`

## Tear down a cluster
```
ansible-playbook reset.yml -i inventory/prime-cluster/hosts.yml --ask-become-pass
```

Sporadically firewall can cause issues when redeploying the cluster (`coredns` pod is in failed state), to solve this flush the `iptables` and restart docker in order to populate the rules again.

```
sudo iptables -F
sudo systemctl restart docker
```
