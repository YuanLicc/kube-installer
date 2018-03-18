#!/bin/bash
# create token and file token.csv

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create BOOTSTRAP_TOKEN
export BOOTSTRAP_TOKEN_TMP=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] BOOTSTRAP_TOKEN is $BOOTSTRAP_TOKEN_TMP

if [ -f "/etc/kubernetes/token.csv" ]; then
  rm -f /etc/kubernetes/token.csv
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/token.csv
echo -e "${BOOTSTRAP_TOKEN_TMP},kubelet-bootstrap,10001,\"system;kubelet-bootstrap\"" >> /etc/kubernetes/token.csv


# create kubeconfig
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config cluster parameters
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_APISERVER} --kubeconfig=bootstrap.kubeconfig

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config client credentials
kubectl config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN_TMP} --kubeconfig=bootstrap.kubeconfig

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config context
kubectl config set-context default --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=bootstrap.kubeconfig

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config default context
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig


echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config cluster parameters
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_APISERVER} --kubeconfig=kube-proxy.kubeconfig


echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config client credentials
kubectl config set-credentials kube-proxy --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config context
kubectl config set-context default --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config default context
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

cp bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/

rm -f bootstrap.kubeconfig
rm -f kube-proxy.kubeconfig
