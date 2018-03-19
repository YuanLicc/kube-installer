# Kubernetes Installer
**Centos**搭建**Kubernetes**脚本
### kube-1.9/kube-install.sh
机器：Centos
机器依赖项：sshpass、yum
证书工具：CFSSL
#### 使用
请先查看kube-install.sh文件,并对相关配置进行修改

使用例子：./kube-install.sh init

| API | 描述  |
|:-------------:|:-------------|
| init | 初始化当前机器 |
| init-cluster | 初始化集群内所有机器（ssh免密、分发脚本、初始化） |
| install-docker | 当前机器安装docker |
| nodes-install-docker | 为所有节点机器安装docker |
| install-cfssl | 当前机器安装cfssl |
| generate-ca | 当前机器生成TLS证书 |
| distribute-ca | 分发TLS证书到所有机器 |
| install-cfssl-gd-ca | 当前机器安装cfssl、生成证书、分发证书到所有机器 |
| install-kubectl | 当前机器安装kubectl |
| generate-tls-token-kubeconfig | 当前机器生成kubernetes跨集群认证证书 |
| distribute-kubeconfig | 分发跨集群证书*.kubeconfig到所有node上 |
| install-etcd | 当前机器安装etcd并对etcd进行配置 |
| install-etcd-cluster | 安装etcd集群，对配置的etcd集群服务器进行etcd的安装（不包含证书文件的分发等，仅仅是安装） |
| start-etcd | 当前机器启动etcd |
| start-etcd-cluster | 启动etcd集群 |
| reset-etcd | 重置etcd、这将关闭并删除etcd数据 |
| reset-etcd-cluster | 重置集群内所有etcd、这将关闭并删除etcd数据 |
| validate-etcd | 验证etcd集群 |
| install-master | 当前机器安装master |
| install-master-cluster | 当前机器及其他master机器安装master |
| start-master | 当前机器启动master |
| start-master-cluster | 启动master集群 |

### bin/*
