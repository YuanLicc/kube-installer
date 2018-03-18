#!/bin/bash
# Judge $CFSSL_HOSTS exitable

cfssl_host_describe="please check the environment variable \"CFSSL_HOSTS\",you can edit env-config.sh to set a value (the value is contains the ip of etcd cluster and master cluster, use \",\" to list them, like this: \"120.78.220.145\",\"125.22.551.111\")"

if [ $CFSSL_HOSTS ]; then
  if [ ! -z $CFSSL_HOSTS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl hosts is : $CFSSL_HOSTS
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] kubernetes version is empty, ${cfssl_host_describe}
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] kubernetes version is not found, ${cfssl_host_describe}
  exit 1
fi
