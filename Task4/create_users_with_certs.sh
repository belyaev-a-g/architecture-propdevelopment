#!/bin/bash
#  base64 grisha.csr >> ./grisha-csr.yaml
kubectl apply -f alex-csr.yaml
kubectl certificate approve developer-access
kubectl apply -f grisha-csr.yaml
kubectl certificate approve analyst-access

kubectl get csr developer-access -o jsonpath='{.status.certificate}' | base64 -d > alex.crt
kubectl get csr analyst-access -o jsonpath='{.status.certificate}' | base64 -d > grisha.crt

# Create namespace task4
kubectl apply -f namespace.yaml
kubectl apply -f roles.yaml
kubectl apply -f bindings.yaml

# Use alex as developer at kubectl
kubectl config set-credentials developer --client-certificate=alex.crt --client-key=alex.key --embed-certs=true
kubectl config set-context dev-context --cluster=minikube --user=developer
kubectl config use-context dev-context

# Use grisha as analyst at kubectl
kubectl config set-credentials analyst --client-certificate=grisha.crt --client-key=grisha.key --embed-certs=true
kubectl config set-context analyst-context --cluster=minikube --user=analyst
kubectl config use-context analyst-context



kubectl config use-context dev-context
echo "Test of alex for namespace task4"
kubectl get pods -n task4
echo "Test of alex for all cluster"
kubectl get pods
# expected - Error from server (Forbidden): pods is forbidden: User "alex" cannot list resource "pods" in API group "" in the namespace "default"



kubectl config use-context analyst-context
echo "Test of grisha for namespace task4"
kubectl get pods -n task4
echo "Test of grisha for all cluster"
kubectl get pods

