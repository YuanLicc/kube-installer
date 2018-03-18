#!/bin/bash
# install kubernetes node

cd /etc/kubernetes

kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap

# download kubernetes-server-linux-amd64.tar.gz
if [ ! -f "/usr/local/installer/${KUBE_VERSION}-kubernetes-server-linux-amd64.tar.gz" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] download file kubernetes-server-linux-amd64.tar.gz
  wget https://dl.k8s.io/${KUBE_VERSION}/kubernetes-server-linux-amd64.tar.gz

  if [ ! -f "kubernetes-server-linux-amd64.tar.gz" ]; then
  	echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
  	eixt 1
  fi
fi

# tar the installer package
tar -zxvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
tar -zxvf kubernetes-src.tar.gz
cp -r ./server/bin{kube-proxy,kubelet} /usr/local/bin/

# rm tared file
cd ..
rm -f kubernetes

# mv kubernetes-server-linux-amd64.tar.gz to /usr/local/installer/kubernetes-server-linux-amd64.tar.gz
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move installer package to /usr/local/installer/
mv kubernetes-server-linux-amd64.tar.gz /usr/local/installer/kubernetes-server-linux-amd64.tar.gz

# rm the kubelet.service
if [ -f "/usr/lib/systemd/system/kubelet.service" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] rm file kubelet.service
  rm -f /usr/lib/systemd/system/kubelet.service
fi

# config kubelet.service
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file kubelet.service and config
echo -e "[Unit]\nDescription=Kubernetes Kubelet Server \nDocumentation=https://github.com/GoogleCloudPlatform/kubernetes\nAfter=docker.service\nRequires=docker.service\n[Service]\nWorkingDirectory=/var/lib/kubelet\nEnvironmentFile=-/etc/kubernetes/config\nEnvironmentFile=-/etc/kubernetes/kubelet\nExecStart=/usr/local/bin/kubelet \$KUBE_LOGTOSTDERR \$KUBE_LOG_LEVEL \$KUBELET_API_SERVER \$KUBELET_ADDRESS \$KUBELET_PORT \$KUBELET_HOSTNAME \$KUBE_ALLOW_PRIV \$KUBELET_POD_INFRA_CONTAINER \$KUBELET_ARGS\nRestart=on-failure\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/kubelet.service

# rm the /etc/kubernetes/kubelet
if[ -f "/etc/kubernetes/kubelet" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] rm file /etc/kubernetes/kubelet
  rm -f /etc/kubernetes/kubelet
fi

# config /etc/kubernetes/kubelet
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/kubelet and config
echo -e "KUBELET_ADDRESS=\"--address=${KUBELET_ADDRESS}\"\nKUBELET_HOSTNAME=\"--hostname-override=${HOST_NAME}\"\nKUBELET_API_SERVER=\"--api-servers=${KUBELET_API_SERVER}\"\nKUBELET_POD_INFRA_CONTAINER=\"--pod-infra-container-image=sz-pg-oam-docker-hub-001.tendcloud.com/library/pod-infrastructure:rhel7\"\nKUBELET_ARGS=\"--cgroup-driver=systemd --cluster-dns=10.254.0.2 --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --require-kubeconfig --cert-dir=/etc/kubernetes/ssl --cluster-domain=cluster.local --hairpin-mode promiscuous-bridge --serialize-image-pulls=false\"" >> /etc/kubernetes/kubelet

# edit /etc/kubernetes/kubelet ip
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create dir /var/lib/kubelet

# rm dir /var/lib/kubelet
if [ -d "/etc/kubernetes/kubelet" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] rm dir /var/lib/kubelet
  rm -f /var/lib/kubelet
fi

# create dir /var/lib/kubelet
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create dir /var/lib/kubelet
mkdir /var/lib/kubelet

# start kubelet
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet

# install kube-proxy
# install conntrack
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] install conntrack
yum install -y conntrack-tools

# config /usr/lib/systemd/system/kube-proxy.service
# rm file /usr/lib/systemd/system/kube-proxy.service
if [ -f "/usr/lib/systemd/system/kube-proxy.service" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] rm file /usr/lib/systemd/system/kube-proxy.service
  rm -f /usr/lib/systemd/system/kube-proxy.service
fi

# config kube-proxy.service
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config kube-proxy.service
echo -e "[Unit]\nDescription=Kubernetes Kube-Proxy Server\nDocumentation=https://github.com/GoogleCloudPlatform/kubernetes\nAfter=network.target\n[Service]\nEnvironmentFile=-/etc/kubernetes/config\nEnvironmentFile=-/etc/kubernetes/proxy\nExecStart=/usr/local/bin/kube-proxy \$KUBE_LOGTOSTDERR \$KUBE_LOG_LEVEL \$KUBE_MASTER \$KUBE_PROXY_ARGS\nRestart=on-failure\nLimitNOFILE=65536\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/kube-proxy.service

# config /etc/kubernetes/proxy
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config /etc/kubernetes/proxy
echo -e "KUBE_PROXY_ARGS=\"--bind-address=${KUBELET_ADDRESS} --hostname-override=${HOST_NAME} --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig --cluster-cidr=10.254.0.0/16\""

# start kube-proxy
systemctl stop kube-proxy
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
