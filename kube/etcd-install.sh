#install etcd service

if [ -f "etcd-${ETCD_VERSION}-linux-amd64.tar.gz" ]; then
  rm -f etcd-${ETCD_VERSION}-linux-amd64.tar.gz
fi

if [ ! -f "/usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] installer package is not found, download etcd-${ETCD_VERSION}-linux-amd64.tar.gz -- $ETCD_VERSION
  wget https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
  
  if [ ! -f "etcd-${ETCD_VERSION}-linux-amd64.tar.gz" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi

  if [ ! -d "/usr/local/installer" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /usr/local/installer is not exit, create it
    mkdir /usr/local/installer
    chmod 777 /usr/local
    chmod 777 /usr/local/installer
  fi

  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move installer package to /usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz
  mv etcd-${ETCD_VERSION}-linux-amd64.tar.gz /usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz
fi

chmod 777 /usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] tar installer package:/usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -zxvf /usr/local/installer/${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64.tar.gz

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move ${ETCD_VERSION}-etcd-${ETCD_VERSION}-linux-amd64/etcd* to /usr/local/bin
mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin

chmod 777 /usr/local/bin/etcd*

rm -rf etcd-${ETCD_VERSION}-linux-amd64

if [ -f "/usr/lib/systemd/system/etcd.service" ]; then
  rm -f /usr/lib/systemd/system/etcd.service
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /usr/lib/systemd/system/etcd.service and write configurations
echo -e "[Unit]\nDescription=Etcd Server\nAfter=network.target\nAfter=network-online.target\nWants=network-online.target\nDocumentation=https://github.com/coreos\n\n[Service]\nType=notify\nWorkingDirectory=/var/lib/etcd/\nEnvironmentFile=-/etc/etcd/etcd.conf\nExecStart=/usr/local/bin/etcd --name ${ETCD_NAME} --cert-file=/etc/kubernetes/ssl/kubernetes.pem --key-file=/etc/kubernetes/ssl/kubernetes-key.pem --peer-cert-file=/etc/kubernetes/ssl/kubernetes.pem --peer-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --trusted-ca-file=/etc/kubernetes/ssl/ca.pem --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem --initial-advertise-peer-urls https://${ETCD_SERVER_ADDRESS}:2380 --listen-peer-urls https://${ETCD_SERVER_ADDRESS}:2380 --listen-client-urls https://${ETCD_SERVER_ADDRESS}:2379,http://127.0.0.1:2379 --advertise-client-urls https://${ETCD_SERVER_ADDRESS}:2379 --initial-cluster-token=etcd-cluster --initial-cluster ${ETCD_CLUSTERS} --initial-cluster-state=new --data-dir=/var/lib/etcd\nRestart=on-failure\nRestartSec=5\nLimitNOFILE=65536\n\n[Install]\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/etcd.service

if [ -f "/etc/etcd/etcd.conf" ]; then
  rm -f /etc/etcd/etcd.conf
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] create file /etc/etcd/etcd.conf and write configurations
echo -e "ETCD_NAME=${ETCD_NAME}\nETCD_DATA_DIR=\"/var/lib/etcd\"\nETCD_LISTEN_PEER_URLS=\"${ETCD_SERVER_ADDRESS}\"\nETCD_LISTEN_CLIENT_URLS=\"${ETCD_SERVER_ADDRESS}:2379\"\nETCD_INITIAL_ADVERTISE_PEER_URLS=\"${ETCD_SERVER_ADDRESS}:2380\"\nETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster\"\nETCD_ADVERTISE_CLIENT_URLS=\"${ETCD_SERVER_ADDRESS}:2379\"" >> /etc/etcd/etcd.conf

if [ ! -d "/var/lib/etcd" ]; then
  mkdir /var/lib/etcd
fi
