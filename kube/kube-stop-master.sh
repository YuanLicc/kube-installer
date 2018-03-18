echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] Stop kube master
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] Stop server kube-scheduler
systemctl stop kube-scheduler
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] Stop server kube-controller-manager
systemctl stop kube-controller-manager
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] Stop server kube-apiserver
systemctl stop kube-apiserver
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] Stop server etcd
systemctl stop etcd
