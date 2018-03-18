#!/bin/bash
# check environment variable KUBE_APISERVER

if [ $KUBE_APISERVER ]; then
  if [ -z $KUBE_APISERVER ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] environment variable:KUBE_APISERVER is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] environment variable:KUBE_APISERVER not found
  exit 1
fi
