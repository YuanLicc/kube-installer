# Kubernetes Installer
**Centos**搭建**Kubernetes**脚本
### kubeHA-1.9/kube-install.sh
机器：Centos
机器依赖项：sshpass、yum
证书工具：CFSSL

使用例子：./kube-install.sh init

| API | 描述  |
|:-------------:|:-------------|
| init | 初始化当前机器 |
| init-cluster | 初始化集群内所有机器（ssh免密、分发脚本、初始化） |
| install-cfssl | 当前机器安装cfssl |
| generate-ca | 当前机器生成TLS证书 |
| distribute-ca | 分发TLS证书到etcd集群的所有机器 |
| install-cfssl-gd-ca | 当前机器安装cfssl、生成证书、分发证书到etcd集群的所有机器 |
| install-etcd | 当前机器安装etcd并对etcd进行配置 |
| install-etcd-cluster | 安装etcd集群，对配置的etcd集群服务器进行etcd的安装（不包含证书文件的分发等，仅仅是安装） |
| start-etcd | 当前机器启动etcd |
| start-etcd-cluster | 启动etcd集群 |
| reset-etcd | 重置etcd、这将关闭并删除etcd数据 |
| reset-etcd-cluster | 重置集群内所有etcd、这将关闭并删除etcd数据 |
| validate-etcd | 验证etcd集群 |

### bin/*
