#!/bin/bash
# check CONFIG_IP

if [ $CONFIG_IP ]; then
  if [ -z $CONFIG_IP ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] CONFIG_IP is empty
    exit 1
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] CONFIG_IP is not found
  exit 1
fi
