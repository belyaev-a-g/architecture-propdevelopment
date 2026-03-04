#!/bin/bash
# Запускать minikube с calico - иначе сетевые правила не будут выполняться
# minikube start --cni=calico
# Возможно, что правило блокировать всё по-умолчанию и не нужно

# Определяем переменную для Namespace
NS="task-5"

echo "Удаляю namespace $NS"
kubectl delete ns $NS --ignore-not-found

echo "Создаю namespace $NS"
kubectl create ns $NS

# Создание целевых подов
echo "Создание целевых подов в $NS..."
kubectl run front-end-app --image=nginx --labels role=front-end -n $NS --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api -n $NS --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end -n $NS --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api -n $NS --expose --port 80

# Создание тестового пода.
echo "Создание тестового пода..."
kubectl run test-pod --image=alpine --labels role=front-end -n $NS -- sh -c "sleep 3600"

# Ожидание готовности
echo "Ожидание готовности в $NS..."
kubectl wait --for=condition=Ready pod -n $NS --all --timeout=90s

# Применение политик
echo "Applying Network Policies..."
# Важно: убедитесь, что в YAML файле либо нет namespace, либо он совпадает с $NS
kubectl apply -f non-admin-api-allow.yaml -n $NS

# Выполнение тестов
echo "------------------------------------------------"
echo "TEST 1: front-end -> back-end-api (Expected: SUCCESS)"
# Проверяем доступность
kubectl exec test-pod -n $NS -- wget -qO- --timeout=2 http://back-end-api-app > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "RESULT: [ OK ]"; else echo "RESULT: [ FAILED ]"; fi

echo "------------------------------------------------"
echo "TEST 2: front-end -> admin-back-end-api (Expected: TIMEOUT)"
# Проверяем блокировку
kubectl exec test-pod -n $NS -- wget -qO- --timeout=2 http://admin-back-end-api-app > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "RESULT: [ SUCCESS: BLOCKED ]"; else echo "RESULT: [ FAILED: ACCESS LEAK ]"; fi
echo "------------------------------------------------"

echo "Testing finished in namespace: $NS"

