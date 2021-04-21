#!/bin/bash

export MASTER_NODE=zprime-09.hftex

scp -i ~/.ssh/fidexx/office.rsa -r prime@$MASTER_NODE:~/.kube/config ~/.kube/k3s_config

export KUBECONFIG=~/.kube/k3s_config
export NAMESPACE=staging

./ecr.sh

# INGRESS

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

kubectl apply -f resources/issuer-staging.yaml
kubectl apply -f resources/issuer-prod.yaml

export KUBECONFIG=''
