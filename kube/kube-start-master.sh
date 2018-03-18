echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] start kube-apiserver
systemctl stop kube-apiserver
systemctl enable kube-apiserver
systemctl start kube-apiserver

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] start kube-controller-manager
systemctl stop kube-controller-manager
systemctl enable kube-controller-manager
systemctl start kube-controller-manager

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] start kube-scheduler
systemctl stop kube-scheduler
systemctl enable kube-scheduler
systemctl start kube-scheduler

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] see statuses of kubernetes components
kubectl get componentstatuses
