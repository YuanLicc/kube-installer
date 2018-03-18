#!/bin/bash
# scp from special master

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] check enviroment variables
source ./all-env.sh

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] run scp
source ./scp.sh
