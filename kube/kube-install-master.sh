nstall kubernetes master

if [ -f "kubernetes-server-linux-amd64.tar.gz" ]; then
  rm -rf kubernetes-server-linux-amd64.tar.gz
fi

chmod 777 /usr/local

chmod 777 /usr/local/installer

if [ ! -f "/usr/local/installer/${KUBE_VERSION}-kubernetes-server-linux-amd64.tar.gz" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] installer package is not found, download kubernetes-server-linux-amd64.tar.gz -- $KUBE_VERSION
  wget https://dl.k8s.io/$KUBE_VERSION/kubernetes-server-linux-amd64.tar.gz
  
  if [ ! -f "kubernetes-server-linux-amd64.tar.gz" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi

  if [ ! -d "/usr/local/installer" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /usr/local/installer is not exit, create it
    mkdir /usr/local/installer
    chmod 777 /usr/local
    chmod 777 /usr/local/installer
  fi

  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move installer package to /usr/local/installer/$KUBE_VERSION-kubernetes-server-linux-amd64.tar.gz
  mv kubernetes-server-linux-amd64.tar.gz /usr/local/installer/$KUBE_VERSION-kubernetes-server-linux-amd64.tar.gz
fi

chmod 777 /usr/local/installer/$KUBE_VERSION-kubernetes-server-linux-amd64.tar.gz

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] decompression the file /usr/local/installer/$KUBE_VERSION-kubernetes-server-amd64.tar.gz
tar -zxvf /usr/local/installer/$KUBE_VERSION-kubernetes-server-linux-amd64.tar.gz

chmod 777 kubernetes

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cd kubernetes
cd kubernetes

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] decompression the file kubernetes/kubernetes-src.tar.gz
tar -xzvf kubernetes-src.tar.gz

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] copy kubernetes/server/bin/kube-apiserver... to /usr/local/
cp -r  server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet} /usr/local/bin/

chmod 777 /usr/local/bin/*

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] delete dir kubernetes
cd ..
rm -rf kubernetes

if [ -f "/usr/lib/systemd/system/kube-apiserver.service" ]; then
  rm -f /usr/lib/systemd/system/kube-apiserver.service
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /usr/lib/systemd/system/kube-apiserver.service and write configurations
echo -e "[Unit]\nDescription=Kubernetes API Service\nDocumentation=https://github.com/GoogleCloudPlatform/kubernetes\nAfter=network.target\nAfter=etcd.service\n\n[Service]\nEnvironmentFile=-/etc/kubernetes/config\nEnvironmentFile=-/etc/kubernetes/apiserver\nExecStart=/usr/local/bin/kube-apiserver --logtostderr=true --v=0 --etcd-servers=${ETCD_SERVERS} --advertise-address=${KUBE_MASTER_ADDRESS} --bind-address=${KUBE_MASTER_ADDRESS} --insecure-bind-address=${KUBE_MASTER_ADDRESS} --insecure-port=$KUBE_API_PORT --kubelet-port=$KUBELET_PORT --allow-privileged=true --service-cluster-ip-range=10.254.0.0/16 --admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota --authorization-mode=RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1 --kubelet-https=true --experimental-bootstrap-token-auth --token-auth-file=/etc/kubernetes/token.csv --service-node-port-range=10250-32767 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --client-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --enable-swagger-ui=true --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/lib/audit.log --event-ttl=1h\nRestart=on-failure\nType=notify\nLimitNOFILE=65536\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/kube-apiserver.service

if [ ! -d "/etc/kubernetes" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /etc/kubernetes is not found
  mkdir /etc/kubernetes
fi

chmod 777 /etc/kubernetes

if [ -f "/etc/kubernetes/config" ]; then
  rm -f /etc/kubernetes/config
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/config and write configurations
echo -e "KUBE_LOGTOSTDERR=\"--logtostderr=true\"\nKUBE_LOG_LEVEL=\"--v=0\"\nKUBE_ALLOW_PRIV=\"--allow-privileged=true\"\nKUBE_MASTER=\"--master=${KUBE_MASTER}\"" >> /etc/kubernetes/config

chmod 777 /etc/kubernetes/config

if [ -f "/etc/kubernetes/apiserver" ]; then
  rm -f /etc/kubernetes/apiserver
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/apiserver and write configurations
echo -e "KUBE_API_ADDRESS=\"--advertise-address=${KUBE_MASTER_ADDRESS} --bind-address=${KUBE_MASTER_ADDRESS} --insecure-bind-address=${KUBE_MASTER_ADDRESS}\"\nKUBE_ETCD_SERVERS=\"--etcd-servers=${ETCD_SERVERS}\"\nKUBE_SERVICE_ADDRESSES=\"--service-cluster-ip-range=10.254.0.0/16\"\nKUBE_ADMISSION_CONTROL=\"--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota\"\nKUBE_API_ARGS=\"--authorization-mode=RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1 --kubelet-https=true --experimental-bootstrap-token-auth --token-auth-file=/etc/kubernetes/token.csv --service-node-port-range=30000-32767 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --client-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --enable-swagger-ui=true --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/lib/audit.log --event-ttl=1h\"" >> /etc/kubernetes/apiserver

chmod 777 /etc/kubernetes/apiserver

if [ -f "/usr/lib/systemd/system/kube-controller-manager.service" ]; then
  rm -f /usr/lib/systemd/system/kube-controller-manager.service
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /usr/lib/systemd/system/kube-controller-manager.service and write configurations
echo -e "[Unit]\nDescription=Kubernetes Controller Manager\nDocumentation=https://github.com/GoogleCloudPlatform/kubernetes\n[Service]\nEnvironmentFile=-/etc/kubernetes/config\nEnvironmentFile=-/etc/kubernetes/controller-manager\nExecStart=/usr/local/bin/kube-controller-manager \$KUBE_LOGTOSTDERR \$KUBE_LOG_LEVEL \$KUBE_MASTER \$KUBE_CONTROLLER_MANAGER_ARGS\nRestart=on-failure\nLimitNOFILE=65536\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/kube-controller-manager.service

if [ -f "/etc/kubernetes/controller-manager" ]; then
  rm -f /etc/kubernetes/controller-manager
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/controller-manager and write configurations
echo -e "KUBE_CONTROLLER_MANAGER_ARGS=\"--address=127.0.0.1 --service-cluster-ip-range=10.254.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem --root-ca-file=/etc/kubernetes/ssl/ca.pem --leader-elect=true\"" >> /etc/kubernetes/controller-manager

chmod 777 /etc/kubernetes/controller-manager

if [ -f "/usr/lib/systemd/system/kube-scheduler.service" ]; then
  rm -f /usr/lib/systemd/system/kube-scheduler.service
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /usr/lib/systemd/system/kube-scheduler.service and write configurations
echo -e "[Unit]\nDescription=Kubernetes Scheduler Plugin\nDocumentation=https://github.com/GoogleCloudPlatform/kubernetes\n[Service]\nEnvironmentFile=-/etc/kubernetes/config\nEnvironmentFile=-/etc/kubernetes/scheduler\nExecStart=/usr/local/bin/kube-scheduler \$KUBE_LOGTOSTDERR \$KUBE_LOG_LEVEL \$KUBE_MASTER \$KUBE_SCHEDULER_ARGS\nRestart=on-failure\nLimitNOFILE=65536\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/kube-scheduler.service

if [ -f "/etc/kubernetes/scheduler" ]; then
  rm -f /etc/kubernetes/scheduler
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/kubernetes/scheduler and write configurations
echo -e "KUBE_SCHEDULER_ARGS=\"--leader-elect=true --address=127.0.0.1\"" >> /etc/kubernetes/scheduler

chmod 777 /etc/kubernetes/scheduler
