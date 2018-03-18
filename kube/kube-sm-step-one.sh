#!/bin/bash
# contains part of operate

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] check all env
source ./all-env.sh

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] install cfssl
source ./cfssl-install.sh

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create ca
source ./cfssl-create-ca.sh

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] install kubectl
source ./kube-install-kubectl.sh

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create *.kubeconfig
source ./kube-token-kubeconfig.sh
