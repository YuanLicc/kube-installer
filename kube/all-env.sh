#!/bin/bash
# 环境变量配置文件

# 关于下面的例子，都是建立在这样的集群下：
# 搭建kubernetes集群：master服务器：120.77.124.33、120.77.124.34，etcd服务器：120.77.124.33、120.77.124.35，
# 节点服务器：120.77.124.36、120.77.124.37

# 1.CFSSL_HOSTS: 包含Master集群服务器地址、etcd集群服务器地址，master与etcd是可以在同一个服务器（120.77.124.33）上的，例子：
# CFSSL_HOSTS="\"120.77.124.33\",\"120.77.124.34\",\"120.77.124.35\""
# 请在下面配置这个变量
CFSSL_HOSTS="\"120.77.171.82\",\"111.230.227.12\""

# 2.KUBE_VERSION: kubernetes的版本，默认为v1.6.0，可以不设置，默认设置为v1.6.0
# 请在下面配置这个变量
KUBE_VERSION="v1.6.0"

# 3.KUBE_APISERVER: kubernetes的master安装命令工具kubectl的ip地址及端口，假如当前正在120.77.124.33这个服务器（master）安装kubectl，
# 那么值应该是这样的：120.77.124.33:6443，一般我们使用6443端口，也可以使用其它端口，但是为了避免与后面设置其它服务端口时冲突，就设置6443端口。
# 请在下面配置这个变量
KUBE_APISERVER="120.77.171.82:8080"

# 4.ETCD_VERSION: etcd的版本，默认为v3.1.5，可以不设置，默认设置为v3.1.5
# 请在下面配置这个变量
ETCD_VERSION="v3.1.5"

# 5.ETCD_NAME: etcd的的名称，例子：infra1、infra2、infra2，代表etcd集群中一个etcd的名称，他们不能相同
# 请在下面配置这个变量
ETCD_NAME="etcd-one"

# 6.ETCD_SERVER_ADDRESS：安装etcd的服务器地址，例子：120.77.124.33
# 请在下面配置这个变量
ETCD_SERVER_ADDRESS="120.77.171.82"

# 7.ETCD_CLUSTERS：etcd集群所在服务器地址集合，例子：infra1=https://120.77.124.33:2380,infra2=https://120.77.124.34:2380
# 很显然它是etcd的名称与所在服务器地址与端口号组成。这里端口2380不要去改变
# 请在下面配置这个变量
ETCD_CLUSTERS="etcd-one=https://120.77.171.82:2380,etcd-two=https://111.230.227.12:2380"

# 7.ETCD_SERVERS：etcd集群所在服务器地址集合，例子：https://120.77.124.33:2379,https://120.77.124.34:2379
# 很显然它是etcd的名称与所在服务器地址与端口号组成。这里端口2379不要去改变
# 请在下面配置这个变量
ETCD_SERVERS="https://120.77.171.82:2379,https://111.230.227.12:2379"

# 8.KUBE_MASTER：kubernetes中master所在服务器的ip+端口，即当前服务器的地址，此变量将用来安装kubernetes的master，
# 并进行配置，务必使得安装master的服务器ip与此相同，例子：120.77.124.33:8080
# 可以修改后面的端口号
# 请在下面配置这个变量
KUBE_MASTER="120.77.171.82:8080"

# 9.KUBE_API_PORT：前一个配置的端口号
# 请在下面配置这个变量
KUBE_API_PORT="8080"

# 10.KUBE_MASTER_ADDRESS：kubernetes中master所在服务器的ip，即当前服务器的地址，此变量将用来安装kubernetes的master，
# 并进行配置，务必使得安装master的服务器ip与此相同，例子：120.77.124.33
# 请在下面配置这个变量
KUBE_MASTER_ADDRESS="120.77.171.82"

# 11.KUBELET_ADDRESS：安装node时，所在服务器ip地址，即当前服务器（正在安装node）的地址，
# 务必使得安装node的服务器ip与此相同，例子：120.77.124.33
# 请在下面配置这个变量
KUBELET_ADDRESS="120.77.124.33"

# 12.HOST_NAME：安装node时，所在服务器主机名（自定义），即当前服务器（正在安装node）的自定义主机名，
# 一般使用服务器ip作为主机名会比较清晰，例子：120.77.124.33
# 请在下面配置这个变量
HOST_NAME="120.77.171.82"

# 13.KUBELET_API_SERVER：安装node时，指定master的ip，使得node启动后，绑定到master，
# 关于紧跟的端口号，应该与配置master时，变量KUBE_MASTER后紧跟的端口号一致，例子：http://120.77.124.33:8080
# 请在下面配置这个变量
KUBELET_API_SERVER="http://120.77.171.82:8080"

# 14.CONFIG_IP：生成了授权文件的服务器地址，例子：120.77.124.33
# 请在下面配置这个变量
CONFIG_IP="120.77.171.82"

# 14.KUBELET_PORT：默认为10250
# 请在下面配置这个变量
KUBELET_PORT="10250"

source ./cfssl-verify-env.sh

source ./kube-verify-version.sh

source ./kube-kubectl-verify-env.sh

source ./etcd-verify-env.sh

source ./kube-master-verify-env.sh

source ./kube-node-verify-env.sh

source ./scp-verify-env.sh
