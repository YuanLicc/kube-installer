# install flanneld
yum remove -y flanneld

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] install flanneld
yum install -y flannel

if [ -f "/usr/lib/systemd/system/flanneld.service" ]; then
  rm -f /usr/lib/systemd/system/flanneld.service
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /usr/lib/systemd/system/flanneld.service and write configuration
echo -e "[Unit]\nDescription=Flanneld overlay address etcd agent\nAfter=network.target\nAfter=network-online.target\nWants=network-online.target\nAfter=etcd.service\nBefore=docker.service\n[Service]\nType=notify\nEnvironmentFile=/etc/sysconfig/flanneld\nEnvironmentFile=-/etc/sysconfig/docker-network\nExecStart=/usr/bin/flanneld-start -etcd-endpoints=\${FLANNEL_ETCD_ENDPOINTS} -etcd-prefix=\${FLANNEL_ETCD_PREFIX} \$FLANNEL_OPTIONS\nExecStartPost=/usr/libexec/flannel/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker\nRestart=on-failure\n[Install]\nWantedBy=multi-user.target\nRequiredBy=docker.service" >> /usr/lib/systemd/system/flanneld.service

if [ -f "/etc/sysconfig/flanneld" ]; then
  rm -f /etc/sysconfig/flanneld
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/sysconfig/flanneld and write configuration
echo -e "FLANNEL_ETCD_ENDPOINTS=\"${ETCD_SERVERS}\"\nFLANNEL_ETCD_PREFIX=\"/kube-centos/network\"\nFLANNEL_OPTIONS=\"-etcd-cafile=/etc/kubernetes/ssl/ca.pem -etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem -etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem\"" >> /etc/sysconfig/flanneld
