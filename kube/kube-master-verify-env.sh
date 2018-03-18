#!/bin/bash
# check master env

# like 120.78.220.145:8080
if [ $KUBE_MASTER ]; then
  if [ ! -z $KUBE_MASTER ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kube master is $KUBE_MASTER
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'KUBE_MASTER' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'KUBE_MASTER' is not found
  exit 1
fi

if [ $KUBE_API_PORT ]; then
  if [ ! -z $KUBE_API_PORT ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] KUBE_API_PORT is $KUBE_API_PORT
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBE_API_PORT is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBE_API_PORT is not found
  exit 1
fi

if [ $KUBELET_PORT ]; then
  if [ ! -z $KUBELET_PORT ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] KUBELET_PORT is $KUBELET_PORT
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_PORT is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_PORT is not found
  exit 1
fi

# like 120.78.220.145
if [ $KUBE_MASTER_ADDRESS ]; then
  if [ ! -z $KUBE_MASTER_ADDRESS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kube master is $KUBE_MASTER_ADDRESS
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'KUBE_MASTER_ADDRESS' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'KUBE_MASTER_ADDRESS' is not found
  exit 1
fi
