#!/bin/bash
# check etcd environment variables

if [ $ETCD_VERSION ]; then
  if [ ! -z $ETCD_VERSION ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] ETCD version : $ETCD_VERSION
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] ETCD version is not found, set default version : v3.1.5
    export $ETCD_VERSION=v3.1.5
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] ETCD version is not found, set default version : v3.1.5
  export $ETCD_VERSION=v3.1.5
fi

# like https://120.78.220.145
if [ $ETCD_SERVER_ADDRESS ]; then
  if [ ! -z $ETCD_SERVER_ADDRESS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] etcd server is $ETCD_SERVER_ADDRESS
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_SERVER_ADDRESS' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_SERVER_ADDRESS' is not found
  exit 1
fi

if [ $ETCD_NAME ]; then
  if [ ! -z $ETCD_NAME ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] etcd server is $ETCD_NAME
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_NAME' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_NAME' is not found
  exit 1
fi

if [ $ETCD_CLUSTERS ]; then
  if [ ! -z $ETCD_CLUSTERS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] etcd server is $ETCD_CLUSTERS
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_CLUSTERS' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_CLUSTERS' is not found
  exit 1
fi

# like ETCD_SERVERS=https://120.78.220.145:2379,https://120.78.220.146:2379
if [ $ETCD_SERVERS ]; then
  if [ ! -z $ETCD_SERVERS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kube master is $ETCD_SERVERS
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_SERVERS' is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING]  Environment parameter 'ETCD_SERVERS' is not found
  exit 1
fi
