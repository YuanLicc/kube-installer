#!/bin/bash
# install etcd and start it

source ./all-env.sh

source ./etcd-install.sh

systemctl stop etcd

systemctl enable etcd

systemctl daemon-reload

systemctl start etcd
