echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] uninstall kubernetes
yum remove -y kubernetes
yum remove -y kubernetes-client
yum remove -y kubernetes-master
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] uninstall etcd
yum remove -y etcd
