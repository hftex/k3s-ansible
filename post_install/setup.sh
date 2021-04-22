#!/bin/bash

export MASTER_NODE=zprime-09.hftex

scp -i ~/.ssh/fidexx/office.rsa -r prime@$MASTER_NODE:~/.kube/config ~/.kube/k3s_config

export KUBECONFIG=~/.kube/k3s_config
# ecr-credential-helper doesn't work with k3s, as a workaround an authorization token is injected into the cluster as a k8s secret
# Possibly a cron job is needed (to be investigated).
export NAMESPACE=staging

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

kubectl apply -f resources/issuer-staging.yaml -n $NAMESPACE
kubectl apply -f resources/issuer-prod.yaml -n $NAMESPACE

export KUBECONFIG=''

echo "\
####################################################
DON'T FORGET TO UPDATE KUBECONFIG ON GITHUB RUNNERS!
####################################################\
"
