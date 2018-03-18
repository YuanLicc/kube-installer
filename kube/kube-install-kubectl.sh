# download and install kubectl
if [ ! -f "/usr/local/installer/${KUBE_VERSION}-kubernetes-client-linux-amd64.tar.gz" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] installer package is not found, download kubernetes-client-linux-amd64.tar.gz -- $KUBE_VERSION
  wget https://dl.k8s.io/$KUBE_VERSION/kubernetes-client-linux-amd64.tar.gz
  
  if [ ! -f "kubernetes-client-linux-amd64.tar.gz" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi

  if [ ! -d "/usr/local/installer" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /usr/local/installer is not exit, create it
    mkdir /usr/local/installer
    chmod 777 /usr/local
    chmod 777 /usr/local/installer
  fi

  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move installer package to /usr/local/installer/$KUBE_VERSION-kubernetes-client-linux-amd64.tar.gz
  mv kubernetes-client-linux-amd64.tar.gz /usr/local/installer/$KUBE_VERSION-kubernetes-client-linux-amd64.tar.gz
fi

chmod 777 /usr/local/installer/*

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] decompression the file /usr/local/installer/$KUBE_VERSION-kubernetes-client-amd64.tar.gz
tar -xzvf /usr/local/installer/$KUBE_VERSION-kubernetes-client-linux-amd64.tar.gz

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] copy kubernetes/client/bin/kube* to /usr/bin/
cp kubernetes/client/bin/kube* /usr/bin

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] delete dir kubernetes
rm -rf kubernetes

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod /usr/bin/kube*
chmod a+x /usr/bin/kube*

# config kubectl

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config cluster parameters
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_APISERVER}

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config client Authentication parameters
kubectl config set-credentials admin --client-certificate=/etc/kubernetes/ssl/admin.pem --embed-certs=true --client-key=/etc/kubernetes/ssl/admin-key.pem

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config context parameters
kubectl config set-context kubernetes --cluster=kubernetes --user=admin

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] config default context
kubectl config use-context kubernetes

cp /root/.kube/config /etc/kubernetes/kubelet.kubeconfig
