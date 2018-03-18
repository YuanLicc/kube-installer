#!/bin/bash
# create CA by cfssl
# etcd : ca.pem kubernetes-key.pem kubernetes.pem
# kube-apiserver : ca.pem kubernetes-key.pem kubernetes.pem
# kubelet : ca.pem
# kube-proxy : ca.pem kube-proxy.pem kube-proxy-key.pem
# kubectl : ca.pem admin-key.pem admin.pem
# kube-controller-manager : ca-key.pem ca.pem

currentdir=`pwd`

if [ -f "/root/ssl/ca-config.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/ca-config.json is exit,delete it
  chmod +x /root/ssl/ca-config.json
  rm -f /root/ssl/ca-config.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /root/ssl/ca-config.json
touch /root/ssl/ca-config.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod file /root/ssl/ca-config.json
chmod +x /root/ssl/ca-config.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] write json of ca-config to /root/ssl/ca-config.json
echo -e "{\"signing\":{\"default\": {\"expiry\": \"87600h\"},\"profiles\":{\"kubernetes\":{\"usages\":[\"signing\",\"key encipherment\",\"server auth\",\"client auth\"],\"expiry\":\"87600h\"}}}}" >> /root/ssl/ca-config.json

if [ -f "/root/ssl/ca-csr.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/ca-csr.json is exit,delete it
  chmod +x /root/ssl/ca-csr.json
  rm -f /root/ssl/ca-csr.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /root/ssl/ca-csr.json
touch /root/ssl/ca-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod file /root/ssl/ca-csr.json
chmod +x /root/ssl/ca-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] write json of ca-csr to file /root/ssl/ca-csr.json 
echo -e "{\"CN\":\"kubernetes\",\"key\":{\"algo\":\"rsa\",\"size\":2048},\"name\":[{\"C\":\"CN\",\"ST\":\"BeiJing\",\"L\":\"BeiJing\",\"O\":\"k8s\",\"OU\":\"system\"}]}" > /root/ssl/ca-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cd /root/ssl
cd /root/ssl

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create token of ca from file ca-csr.json
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

if [ -f "/root/ssl/kubernetes-csr.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/kubernetes-csr.json is exit,delete it
  chmod +x /root/ssl/kubernetes-csr.json
  rm -f /root/ssl/kubernetes-csr.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /root/ssl/kubernetes-csr.json
touch /root/ssl/kubernetes-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod file /root/ssl/kubernetes-csr.json
chmod +x /root/ssl/kubernetes-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] write json to file /root/ssl/kubernetes-csr.json
echo -e "{\"CN\":\"kubernetes\",\"hosts\":[\"127.0.0.1\",${CFSSL_HOSTS},\"10.254.0.1\",\"kubernetes\",\"kubernetes.default\",\"kubernetes.default.svc\",\"kubernetes.default.svc.cluster\",\"kubernetes.default.svc.cluster.local\"],\"key\":{\"algo\":\"rsa\",\"size\":2048},\"names\":[{\"C\":\"CN\",\"ST\":\"BeiJing\",\"L\":\"BeiJing\",\"O\":\"k8s\",\"OU\":\"System\"}]}" > /root/ssl/kubernetes-csr.json

cd /root/ssl

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create token of kubernetes from file /root/ssl/kubernetes-csr.json
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

if [ -f "/root/ssl/admin-csr.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/admin-csr.json is exit,delete it
  chmod +x /root/ssl/admin-csr.json
  rm -f /root/ssl/admin-csr.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /root/ssl/admin-csr.json
touch /root/ssl/admin-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod file /root/ssl/admin-csr.json
chmod +x /root/ssl/admin-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] write json to file /root/ssl/admin-csr.json
echo -e "{\"CN\":\"admin\",\"hosts\":[],\"key\":{\"algo\":\"rsa\",\"size\":2048},\"names\":[{\"C\":\"CN\",\"ST\":\"BeiJing\",\"L\":\"BeiJing\",\"O\":\"system:masters\",\"OU\":\"System\"}]}" > /root/ssl/admin-csr.json

cd /root/ssl

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create token of admin from file /root/ssl/admin-csr.json
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

if [ -f "/root/ssl/kube-proxy-csr.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"`: file /root/ssl/kube-proxy-csr.json is exit,delete it
  chmod +x /root/ssl/kube-proxy-csr.json
  rm -f /root/ssl/kube-proxy-csr.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /root/ssl/kube-proxy-csr.json
touch /root/ssl/kube-proxy-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod file /root/ssl/kube-proxy-csr.json
chmod +x /root/ssl/kube-proxy-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] write json to file /root/ssl/kube-proxy-csr.json
echo -e "{\"CN\":\"system:kube-proxy\",\"hosts\":[],\"key\":{\"algo\":\"rsa\",\"size\":2048},\"names\":[{\"C\":\"CN\",\"ST\":\"BeiJing\",\"L\":\"BeiJing\",\"O\":\"k8s\",\"OU\":\"System\"}]}" > /root/ssl/kube-proxy-csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create ca for kube-proxy by /root/ssl/kube-proxy-csr.json
cd /root/ssl
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy

openssl x509 -noout -text -in kubernetes.pem
cfssl-certinfo -cert kubernetes.pem

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create dir /etc/kubernetes/ssl and copy files of ca to /etc/kubernetes/ssl/
rm -f /etc/kubernetes/ssl/*.pem
mkdir -p /etc/kubernetes/ssl
cp *.pem /etc/kubernetes/ssl

cd ${currentdir}
