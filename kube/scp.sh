#!/bin/bash
# copy from master

if [ ! -d "/etc/kubernetes" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /etc/kubernetes is not found, create dir /etc/kubernetes
  mkdir /etc/kubernetes
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] rm /etc/kubernetes/*.kubeconfig
  rm -f /etc/kubernetes/*.kubeconfig

  if [ -d "/etc/kubernetes/ssl" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] delete dir /etc/kubernetes/ssl
    rm -rf /etc/kubernetes/ssl
  fi
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create dir /etc/kubernetes/ssl
mkdir /etc/kubernetes/ssl

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] copy from ${CONFIG_IP}
scp -r root@${CONFIG_IP}:/etc/kubernetes/*.kubeconfig /etc/kubernetes/

scp -r root@${CONFIG_IP}:/etc/kubernetes/ssl /etc/kubernetes
