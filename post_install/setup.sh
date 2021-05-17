#!/bin/bash

export MASTER_NODE=zprime-09.hftex

scp -i ~/.ssh/fidexx/office.rsa -r prime@$MASTER_NODE:~/.kube/config ~/.kube/k3s_config

export KUBECONFIG=~/.kube/k3s_config

# INGRESS
# Cluster is deployed without an ingress controller (`traefik` by default), so we need to install NGINX.

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx

# TLS

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.3.0 \
  --set installCRDs=true

sleep 15

export NAMESPACE=staging

kubectl apply -f resources/issuer-staging.yaml -n $NAMESPACE
kubectl apply -f resources/issuer-prod.yaml -n $NAMESPACE

export KUBECONFIG=''

echo "\
####################################################
DON'T FORGET TO UPDATE KUBECONFIG ON GITHUB RUNNERS!
####################################################

Execute:

cd cm/github-runners

ansible-vault edit roles/k8s/files/office.kubeconfig  --vault-password-file ~/.ansible/vault-secret

ansible-playbook
  -i inventories/github_runners.yml
  github_runners.yml
  --tags kubeconfig
  --ask-become-pass
  --vault-password-file ~/.ansible/vault-secret
"
