#!/bin/nash
# check environment variables

if [ $KUBELET_ADDRESS ]; then
  if [ -z $KUBELET_ADDRESS ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_ADDRESS is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_ADDRESS is not found
  exit 1
fi

if [ $HOST_NAME ]; then
  if [ -z $HOST_NAME ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] HOST_NAME is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] HOST_NAME is not found
  exit 1
fi

if [ $KUBELET_API_SERVER ]; then
  if [ -z $KUBELET_API_SERVER ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_API_SERVER is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] KUBELET_API_SERVER is not found
  exit 1
fi
