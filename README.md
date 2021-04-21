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
scp -i ~/.ssh/office.rsa -r prime@zprime-09.hftex:~/.kube/config ~/.kube/k3s_config
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
