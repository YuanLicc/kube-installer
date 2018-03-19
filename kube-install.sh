#!/bin/bash
#部署环境变量
# 集群搭建环境
# 1 首先对于etcd集群来说，应该确保服务器在同一个网络环境下
#    对于在公有云（阿里云等）搭建集群，应该确保etcd所在服务器在同一区域内
#    对于vpc网络，请使用服务器的内网ip，对于经典网络，暂时未做任何测试
# 2 对于kubernetes集群来说

# 初始配置项
CAIP=120.78.220.145 # 选定一个服务器作为我们安装集群的操作服务器，意味着我们将在此机器上执行命令来搭建集群，1 生成TLS证书 2 运行命令搭建集群（无论你在什么环境下，请确保此ip能被其他服务器访问，因为我们将执行命令从此服务器复制配置到其它服务器）
INSTALLER_DIR=/usr/local/installer # 安装包存储文件夹,请不要再最后加‘/’符号
ALL_IPS=("120.77.171.82" "111.230.227.12") # 除当前执行脚本外的主机ip集合（即集群内所有主机ip出去当前执行安装的主机ip），我们将对这些服务器进行ssh免密操作，以免频繁输入密码
ALL_IPS_PWD=("yongYUANaiLxP222" "yongYUANaiLxP222") # 上一项对应的密码
ALL_IPS_NAME=("etcd-two" "etcd-three") # 与上两项对应的，请填写名称，将在后续替换ETCD_NAME配置项
ALL_NODE_IP=("120.77.171.82" "111.230.227.12")
ALL_NODE_PWD=("yongYUANaiLxP222" "yongYUANaiLxP222")
MASTER_AND_ETCD_IP=\"120.78.220.145\" # master集群与etcd集群的所有IP集合,以逗号隔开

# CFSSl配置项(cfssl是一个TLS证书的生成工具)
CFSSL_INSTALLER_PREFIX=cfssl*amd64 # cfssl二进制文件的匹配表达式（用于删除当前目录下下载的安装包）
CFSSL_DOWNLOAD_URL=https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 # cfssl二进制文件下载地址
CFSSL_INSTALLER_NAME=cfssl_linux-amd64 # cfssl二进制文件下载到本地的文件名
CFSSLJSON_DOWNLOAD_URL=https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 # cfssljson二进制文件下载地址
CFSSLJSON_INSTALLER_NAME=cfssljson_linux-amd64 # cfssljson二进制文件下载到本地的文件名
CFSSLCERTINFO_DOWNLOAD_URL=https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 # cfssl-certinfo二进制文件下载地址
CFSSLCERTINFO_INSTALLER_NAME=cfssl-certinfo_linux-amd64 # cfssl-certinfo二进制文件下载到本地的文件名

# etcd配置项（etcd为一个键值存储仓库，用于配置共享，服务发现，是kubernetes依赖的组件）
ETCD_NAME=etcd # 当前部署的机器名称(随便定义)
ETCD_CLUSTER_TOKEN=etcd # 当前etcd集群的token，理解为etcd集群唯一的一个名称即可
ETCD_DATA_DIR=/var/lib/etcd/ # etcd数据存放路径
ETCD_LISTEN_IP=172.18.250.166 # 当前部署的机器IP
ETCD_IPS="\"172.18.250.166\"" # etcd 集群所有机器IP
ETCD_NODES=etcd=https://172.18.250.166:2380 # etcd集群间通信的IP和端口
ETCD_IPP=() # etcd 集群机器的IP，除开CAIP
ETCD_IPP_PWD=()
ETCD_VERSION=v3.1.10
ETCD_DOWNLOAD_URL=http://github.com/coreos/etcd/releases/download/v3.1.10/etcd-v3.1.10-linux-amd64.tar.gz
ETCD_INSTALLER_NAME=etcd-v3.1.10-linux-amd64.tar.gz
ETCD_UNZIP_NAME=etcd-v3.1.10-linux-amd64 # etcd加压后文件夹名
ETCD_EXECUTABLE_REGULAR=etcd-v3.1.10-linux-amd64/etcd* # etcd可执行程序模糊表达式

# kubernetes配置项
KUBE_VERSION=v1.6.0 # kubernetes版本
KUBE_API_SERVER=172.18.250.166:8080 # kubernetes API server
KUBE_CLIENT_DOWNLOAD_URL=https://dl.k8s.io/v1.6.0/kubernetes-client-linux-amd64.tar.gz # kubernetes客户端下载地址
KUBE_CLIENT_INSTALLER_NAME=kubernetes-client-linux-amd64.tar.gz # kubernetes客户端下载文件名
KUBE_CLIENT_UNZIP_NAME=kubernetes # kubernetes客户端加压后文件夹名
KUBE_CLIENT_EXECUTABLE_REGULAR=kubernetes/client/bin/kube* # kubernetes客户端可执行程序模糊表达式

# 安装etcd
install_etcd() {
  print_time_and_string "开始安装etcd"

  print_time_and_string "删除当前目录下安装包、解压后文件夹"
  rm -rf $ETCD_INSTALLER_NAME
  rm -rf $ETCD_UNZIP_NAME

  print_time_and_string "判断是否etcd安装包$INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME是否存在"
  check_file_exit $INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME
  etcdInstallerIsExit=$?
  if [ "$etcdInstallerIsExit" != "1" ]; then
    print_time_and_string "检测到etcd安装包$INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME不存在，下载etcd安装包"
    download_wget $ETCD_DOWNLOAD_URL $ETCD_INSTALLER_NAME
    print_time_and_string "将下载的etcd安装包$ETCD_INSTALLER_NAME移动到$INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME"
    mv $ETCD_INSTALLER_NAME $INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME
  else
    print_time_and_string "etcd安装包$INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME已经存在，跳过下载"
  fi
  
  print_time_and_string "解压etcd安装包$INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME"
  tar -xvf $INSTALLER_DIR/$ETCD_VERSION-$ETCD_INSTALLER_NAME
  
  print_time_and_string "将etcd程序移动到/usr/local/bin/下"
  chmod 777 $ETCD_EXECUTABLE_REGULAR
  mv $ETCD_EXECUTABLE_REGULAR /usr/local/bin

  print_time_and_string "删除解压产生的文件夹"
  rm -rf $ETCD_UNZIP_NAME
  print_time_and_string "etcd安装完成，等待配置后启动"

  config_etcd
}

distribute_kubeconfig() {
  print_time_and_string "将集群认证文件*.kubeconfig文件分发到所有NODE"
  i=0  
  while [ $i -lt ${#ALL_NODE_IP[@]} ]  
  do  
    print_time_and_string "分发kubeconfig文件到Node：${ALL_NODE_IP[$i]}"
    sshpass -p ${ALL_NODE_PWD[$i]} scp -r /etc/kubernetes/*.kubeconfig root@${ALL_NODE_IP[$i]}:/etc/kubernetes/
    let i++
  done  
}

generate_tls_token_kubeconfig() {
  print_time_and_string "配置跨集群认证"
  print_time_and_string "生成token码"
  export BOOTSTRAP_TOKEN_TMP=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
  print_time_and_string "$BOOTSTRAP_TOKEN_TMP"

  print_time_and_string "检测/etc/kubernetes/token.csv文件是否存在"
  check_file_exit "/etc/kubernetes/token.csv"
  isTokenExit=$?
  if [ "$isTokenExit" != "0" ]; then
    print_time_and_string "检测/etc/kubernetes/token.csv文件存在，删除它"
    rm -f /etc/kubernetes/token.csv
  else
    print_time_and_string "/etc/kubernetes/token.csv文件不存在"
  fi

  print_time_and_string "生成/etc/kubernetes/token.csv，供kube-apiserver使用"
  cat >  /etc/kubernetes/token.csv <<EOF
${BOOTSTRAP_TOKEN_TMP},kubelet-bootstrap,10001,"system;kubelet-bootstrap"
EOF

  cat /etc/kubernetes/token.csv
  
  print_time_and_string "配置集群参数，写入配置至bootstrap.kubeconfig文件，供kubelet使用"
  kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_API_SERVER} --kubeconfig=bootstrap.kubeconfig

  print_time_and_string "配置客户端认证参数，写入配置至bootstrap.kubeconfig文件，供kubelet使用"
  kubectl config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN_TMP} --kubeconfig=bootstrap.kubeconfig

  print_time_and_string "配置上下文参数，写入配置至bootstrap.kubeconfig文件，供kubelet使用"
  kubectl config set-context default --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=bootstrap.kubeconfig

  print_time_and_string "设置默认上下文，写入配置至bootstrap.kubeconfig文件，供kubelet使用"
  kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

  cat bootstrap.kubeconfig

  print_time_and_string "配置集群参数，写入配置至kube-proxy.kubeconfig文件，供kube-proxy使用"
  kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_API_SERVER} --kubeconfig=kube-proxy.kubeconfig

  print_time_and_string "配置客户端认证参数，写入配置至kube-proxy.kubeconfig文件，供kube-proxy使用"
  kubectl config set-credentials kube-proxy --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

  print_time_and_string "配置上下文参数，写入配置至kube-proxy.kubeconfig文件，供kube-proxy使用"
  kubectl config set-context default --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig

  print_time_and_string "设置默认上下文，写入配置至kube-proxy.kubeconfig文件，供kube-proxy使用"
  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

  print_time_and_string "将生成的bootstrap.kubeconfig、kube-proxy.kubeconfig移动到/etc/kubernetes/"
  cp bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/
  rm -f bootstrap.kubeconfig
  rm -f kube-proxy.kubeconfig
}

# 安装kubectl
install_kubectl() {
  print_time_and_string "安装kubectl"
  print_time_and_string "删除当前目录下安装包"
  rm -f $KUBE_CLIENT_INSTALLER_NAME

  print_time_and_string "删除当前目录下解压后目录$KUBE_CLIENT_UNZIP_NAME"
  rm -rf $KUBE_CLIENT_UNZIP_NAME

  print_time_and_string "检查$INSTALLER_DIR文件夹下是否存在安装包$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME"
  check_file_exit $INSTALLER_DIR/$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME
  isExit=$?
  if [ "$isExit" != "1" ]; then
    print_time_and_string "$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME安装包不存在，下载"
    download_wget $KUBE_CLIENT_DOWNLOAD_URL $KUBE_CLIENT_INSTALLER_NAME

    print_time_and_string "检查安装包$KUBE_CLIENT_INSTALLER_NAME是否下载完成"
    check_file_exit $KUBE_CLIENT_INSTALLER_NAME
    installerIsExit=$?
    if [ "$installerIsExit" != "1" ]; then
      print_time_and_string "安装包$KUBE_CLIENT_INSTALLER_NAME下载失败，无法完成下面的命令"
      exit 1
    else
      print_time_and_string "判定到当前目录下含安装包$KUBE_CLIENT_INSTALLER_NAME（可能只下载了部分，这是不能被检测的）"
      print_time_and_string "将安装包$KUBE_CLIENT_INSTALLER_NAME移动到$INSTALLER_DIR/$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME"
      mv $KUBE_CLIENT_INSTALLER_NAME $INSTALLER_DIR/$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME
    fi
  else
    print_time_and_string "$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME已经存在，跳过下载"
  fi
  
  print_time_and_string "解压安装包$INSTALLER_DIR/$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME"
  tar -zxvf $INSTALLER_DIR/$KUBE_VERSION-$KUBE_CLIENT_INSTALLER_NAME

  print_time_and_string "将可执行程序$KUBE_CLIENT_EXECUTABLE_REGULAR移动到/usr/bin文件夹下"
  cp $KUBE_CLIENT_EXECUTABLE_REGULAR /usr/bin

  print_time_and_string "删除当前目录下解压后目录$KUBE_CLIENT_UNZIP_NAME"
  rm -rf $KUBE_CLIENT_UNZIP_NAME

  print_time_and_string "可执行程序$KUBE_CLIENT_EXECUTABLE_REGULAR添加权限：a+x"
  chmod a+x /usr/bin/kube*

  print_time_and_string "配置集群参数"
  kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/ssl/ca.pem --embed-certs=true --server=${KUBE_API_SERVER}

  print_time_and_string "配置客户端认证参数"
  kubectl config set-credentials admin --client-certificate=/etc/kubernetes/ssl/admin.pem --embed-certs=true --client-key=/etc/kubernetes/ssl/admin-key.pem

  print_time_and_string "配置上下文参数"
  kubectl config set-context kubernetes --cluster=kubernetes --user=admin

  print_time_and_string "设置为默认上下文"
  kubectl config use-context kubernetes
  
  print_time_and_string "将生成文件~/.kube/config，该文件拥有对集群的最高权限，请不要移动它或修改它，可以进行备份"
  print_time_and_string "查看~/.kube/config"
  cat ~/.kube/config
  cp /root/.kube/config /etc/kubernetes/kubelet.kubeconfig
}

# 判断是否安装某工具，参数为工具名
check_installed() {
  count1=`yum list installed | grep $1 |wc -l`
  count2=`rpm -qa | grep $1 |wc -l`
  if [ "$count1" == "0" ]; then
    if [ "$count2" == "0" ]; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

check_ssl_dir() {
  check_dir_exit "/etc/kubernetes/ssl"
  sslDirIsExit=$?
  if [ "$sslDirIsExit" != "1" ]; then
    print_time_and_string "ssl文件夹不存在，进行创建"
    mkdir -p /etc/kubernetes/ssl
    chmod 666 /etc/kubernetes/ssl
  fi
}

check_installer_dir() {
  check_dir_exit $INSTALLER_DIR
  installerDirIsExit=$?
  if [ "$installerDirIsExit" != "1" ]; then
    print_time_and_string "安装包存储文件夹不存在，进行创建"
    mkdir -p $INSTALLER_DIR
    chmod 666 $INSTALLER_DIR
  fi
}

# 每台机器都要进行的初始化
init() {
  print_time_and_string "关闭防火墙"
  systemctl disable firewalld && systemctl stop firewalld

  swapoff -a
  sed 's/.*swap.*/#&/' /etc/fstab

  print_time_and_string "设置SELINUX为disable"
  setenforce 0
  sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
  sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
  sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
  sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

  echo nameserver 114.114.114.114>>/etc/resolv.conf

  cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

  sysctl -p /etc/sysctl.conf
  check_installed "sshpass"
  isInstalledSSHPASS=$?
  if [ "$isInstalledSSHPASS" == "0" ]; then
    print_time_and_string "判断未安装sshpass工具，进行安装"
    yum install -y sshpass
  fi
  check_installer_dir
  check_ssl_dir
}

# 安装docker
install_docker() {
  print_time_and_string "安装docker"
  check_installed "docker"
  dockerIsExit=$?
  if [ "$dockerIsExit" == "0" ]; then
    print_time_and_string "判断未安装docker，进行安装"
    yum install -y docker
  fi
}

nodes_install_docker() {
  i=0
  while [ $i -lt ${#ALL_NODE_IP[@]} ] 
  do  
    print_time_and_string "远程安装docker"
    ssh root@${ALL_NODE_IP[$i]} <<remotessh
      ./kube-install.sh install-docker
    exit
remotessh
    let i++  
  done
}

check_dir_exit() {
  if [ ! -d "$1" ]; then
    return 0
  else
    return 1
  fi
}

check_file_exit() {
  if [ ! -f "$1" ]; then
    return 0
  else
    return 1
  fi
}

# wget下载，参数1：下载地址，参数2：下载后文件名
download_wget() {
  wget $1
  chmod +x $2
}

print_arr() {
  array=$1
  pre=$2
  for var in ${array[*]}
  do
    echo $pre $var
  done
}

print_time_and_string() {
  echo `date "+%Y-%m-%d %H:%M:%S"` $1
}

# 安装cfssl
install_cfssl() {
  print_time_and_string "开始安装cfssl"
  print_time_and_string "删除安装包/usr/local/bin/cfssl*"
  rm -rf /usr/local/bin/cfssl*
  print_time_and_string "删除当前目录下安装包"
  rm -rf $CFSSL_INSTALLER_PREFIX
  # 判断安装包存储路径是否存在，不存在则创建
  check_dir_exit $INSTALLER_DIR
  installerDirIsExit=$?
  if [ "$installerDirIsExit" != "1" ]; then
    print_time_and_string "安装包存储文件夹不存在，进行创建"
    mkdir -p $INSTALLER_DIR
  fi

  # 判断cfssl安装包是否存在，不存在则下载
  check_file_exit $INSTALLER_DIR/$CFSSL_INSTALLER_NAME
  cfsslInstallerIsExit=$?
  if [ "$cfsslInstallerIsExit" != "1" ]; then
    print_time_and_string "cfssl安装包不存在，进行下载"
    download_wget $CFSSL_DOWNLOAD_URL $CFSSL_INSTALLER_NAME
    print_time_and_string "将下载的cfssl安装包移动到${INSTALLER_DIR}目录下"
    mv $CFSSL_INSTALLER_NAME $INSTALLER_DIR/$CFSSL_INSTALLER_NAME
  fi
  print_time_and_string "复制cfssl安装包到/usr/local/bin下并重命名为cfssl"
  cp $INSTALLER_DIR/$CFSSL_INSTALLER_NAME /usr/local/bin/
  mv /usr/local/bin/$CFSSL_INSTALLER_NAME /usr/local/bin/cfssl

  # 判断cfssljson安装包是否存在，不存在则下载
  check_file_exit $INSTALLER_DIR/$CFSSLJSON_INSTALLER_NAME
  cfsslInstallerIsExit=$?
  if [ "$cfsslInstallerIsExit" != "1" ]; then
    print_time_and_string "cfssljson安装包不存在，进行下载"
    download_wget $CFSSLJSON_DOWNLOAD_URL $CFSSLJSON_INSTALLER_NAME
    print_time_and_string "将下载的cfssljson安装包移动到${INSTALLER_DIR}目录下"
    mv $CFSSLJSON_INSTALLER_NAME $INSTALLER_DIR/$CFSSLJSON_INSTALLER_NAME
  fi
  print_time_and_string "复制cfssljson安装包到/usr/local/bin下并重命名为cfssljson"
  cp $INSTALLER_DIR/$CFSSLJSON_INSTALLER_NAME /usr/local/bin/
  mv /usr/local/bin/$CFSSLJSON_INSTALLER_NAME /usr/local/bin/cfssljson

  # 判断cfssl-certinfo安装包是否存在，不存在则下载
  check_file_exit $INSTALLER_DIR/$CFSSLCERTINFO_INSTALLER_NAME
  cfsslcertinfoInstallerIsExit=$?
  if [ "$cfsslcertinfoInstallerIsExit" != "1" ]; then
    print_time_and_string "cfssl-certinfo安装包不存在，进行下载"
    download_wget $CFSSLCERTINFO_DOWNLOAD_URL $CFSSLCERTINFO_INSTALLER_NAME
    print_time_and_string "将下载的cfssl-certinfo安装包移动到${INSTALLER_DIR}目录下"
    mv $CFSSLCERTINFO_INSTALLER_NAME $INSTALLER_DIR/$CFSSLCERTINFO_INSTALLER_NAME
  fi
  print_time_and_string "复制cfssl-certinfo安装包到/usr/local/bin下并重命名为cfssl-certinfo"
  cp $INSTALLER_DIR/$CFSSLCERTINFO_INSTALLER_NAME /usr/local/bin/
  mv /usr/local/bin/$CFSSLCERTINFO_INSTALLER_NAME /usr/local/bin/cfssl-certinfo
}

# 分发证书秘钥到集群下
distribute_ca() {
  pre_string="-"
  info="将证书秘钥文件复制到以下服务器"
  print_time_and_string $info
  i=0  
  while [ $i -lt ${#ALL_IPS[@]} ]  
  do  
    print_time_and_string "将证书秘钥文件复制到${ALL_IPS[$i]}"
    sshpass -p ${ALL_IPS_PWD[$i]} scp -r /etc/kubernetes/ssl/* root@${ALL_IPS[$i]}:/etc/kubernetes/ssl/
    let i++  
  done
}

# 分发脚本到所有机器上
distribute_shell() {
  i=0  
  while [ $i -lt ${#ALL_IPS[@]} ]  
  do
    print_time_and_string "将脚本文件修改并复制到集群主机上"
    cp kube-install.sh /root/
    sed -i "s/^ETCD_NAME=$ETCD_NAME/ETCD_NAME=${ALL_IPS_NAME[$i]}/g" /root/kube-install.sh # 修改ETCD_LISTEN_IP配置
    sed -i "s/^ETCD_LISTEN_IP=$ETCD_LISTEN_IP/ETCD_LISTEN_IP=${ALL_IPS[$i]}/g" /root/kube-install.sh # 修改ETCD_LISTEN_IP配置
    print_time_and_string "脚本文件复制到${ALL_IPS[$i]}"
    sshpass -p ${ALL_IPS_PWD[$i]} scp -r /root/kube-install.sh root@${ALL_IPS[$i]}:/root/
    rm -rf /root/kube-install.sh
    let i++  
  done
}

cfssl_generate_default_config_file() {
  cfssl print-defaults config > config.json
  cfssl print-defaults csr > csr.json
}

# 创建ca配置文件
cfssl_generate_ca_config_file() {
  print_time_and_string "配置ca-config文件"
  cat >  ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF
cat ca-config.json

  print_time_and_string "配置ca-csr文件"
  cat >  ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
cat ca-csr.json 
}

# 生成CA证书与秘钥
cfssl_generate_ca_file() {
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}

# 创建kubernetes证书配置文件
cfssl_generate_kube_config_file() {
  print_time_and_string "配置kubernetes-csr.json文件"
  cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    ${MASTER_AND_ETCD_IP},
    "10.254.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
cat kubernetes-csr.json
}

# 生成kubernetes证书
cfssl_generate_kube_file() {
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
}

cfssl_generate_admin_config_file() {
   print_time_and_string "配置admin-csr文件"
  cat >  admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
cat admin-csr.json  
}

cfssl_generate_admin_file() {
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
}

cfssl_generate_kube_proxy_config_file() {
   print_time_and_string "配置kube-proxy-csr文件"
  cat >  kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
cat kube-proxy-csr.json   
}

cfssl_generate_kube_proxy_file() {
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
}

# ssh免密
ssh_no_pwd() {
  print_time_and_string "进行ssh免密配置"
  check_file_exit "/root/.ssh/id_rsa.pub"
  rsaIsExit=$?
  if [ "$rsaIsExit" != "1" ]; then
    print_time_and_string "判断出本机不包含ssh公钥私钥，生成公钥私钥，下面提示公钥私钥存储位置，请查看是否默认为/root/.ssh/id_rsa，若是则直接回车，不是请填写为/root/.ssh/id_rsa"
    ssh-keygen -t rsa -P ''
  fi
  cp /root/.ssh/id_rsa.pub /root/
  mv /root/id_rsa.pub /root/authorized_keys
  print_time_and_string "将公钥复制到集群主机的/root/.ssh/文件夹下"
  i=0
  while [ $i -lt ${#ALL_IPS[@]} ]  
  do  
    print_time_and_string "将ssh公钥文件复制到${ALL_IPS[$i]}"
    sshpass -p ${ALL_IPS_PWD[$i]} scp -r /root/authorized_keys root@${ALL_IPS[$i]}:/root/.ssh/
    let i++  
  done
  rm -rf /root/authorized_keys
  print_time_and_string "ssh免密配置完成"
}

# 安装etcd集群
install_etcd_cluster() {
  install_etcd
  i=0
  while [ $i -lt ${#ETCD_IPP[@]} ] 
  do  
    print_time_and_string "远程安装并启动etcd服务"
    ssh root@${ETCD_IPP[$i]} <<remotessh
      ./kube-install.sh install-etcd
    exit
remotessh
    let i++  
  done
}

# 初始化整个集群
init_cluster() {
  print_time_and_string "初始化整个集群---开始"
  print_time_and_string "初始化整个集群---进行ssh免密配置"
  ssh_no_pwd # 首先进行ssh免密
  print_time_and_string "初始化整个集群---将依赖的脚本文件复制到集群下每台服务器"
  distribute_shell # 将命令脚本复制到集群下每台服务器下
  print_time_and_string "初始化整个集群---每台服务器进行初始化"
  init
  i=0
  while [ $i -lt ${#ALL_IPS[@]} ]  
  do  
    ssh root@${ALL_IPS[$i]} <<remotessh
      ./kube-install.sh init
    exit
remotessh
    let i++
  done
}

# 配置etcd服务
config_etcd() {
  print_time_and_string "开始配置etcd"
  print_time_and_string "删除etcd工作目录/var/lib/etcd"
  rm -rf /var/lib/etcd
  print_time_and_string "创建etcd工作目录/var/lib/etcd"
  mkdir -p /var/lib/etcd  # 必须先创建工作目录
  print_time_and_string "配置etcd.service文件"
  cat > etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/local/bin/etcd \\
  --name=${ETCD_NAME} \\
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \\
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --peer-cert-file=/etc/kubernetes/ssl/kubernetes.pem \\
  --peer-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --initial-advertise-peer-urls=https://${ETCD_LISTEN_IP}:2380 \\
  --listen-peer-urls=https://${ETCD_LISTEN_IP}:2380 \\
  --listen-client-urls=https://${ETCD_LISTEN_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls=https://${ETCD_LISTEN_IP}:2379 \\
  --initial-cluster-token=${ETCD_CLUSTER_TOKEN} \\
  --initial-cluster=${ETCD_NODES} \\
  --initial-cluster-state=new \\
  --data-dir=${ETCD_DATA_DIR}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  print_time_and_string "将etcd.service文件移动到/etc/systemd/system文件夹下"
  mv etcd.service /etc/systemd/system/
  print_time_and_string "配置etcd完成，等待启动etcd服务"
}

cfssl_generate_all_file() {
  cfssl_generate_default_config_file
  cfssl_generate_ca_config_file
  cfssl_generate_ca_file
  cfssl_generate_kube_config_file
  cfssl_generate_kube_file
  cfssl_generate_admin_config_file
  cfssl_generate_admin_file
  cfssl_generate_kube_proxy_config_file
  cfssl_generate_kube_proxy_file

  print_time_and_string "将证书秘钥复制到/etc/kubernetes/ssl文件夹下"
  cp *.pem *.json *.csr /etc/kubernetes/ssl
  rm -rf *.pem *.json *.csr
}

prepare_etcd_cluster_ca() {
  install_cfssl
  cfssl_generate_all_file
  distribute_ca
}

# 启动etcd服务
start_etcd() {
  print_time_and_string "启动etcd服务"
  print_time_and_string "重载配置文件"
  systemctl daemon-reload
  print_time_and_string "设置etcd开机自启"
  systemctl enable etcd
  print_time_and_string "启动etcd服务"
  systemctl start etcd
  print_time_and_string "若启动etcd出现错误，请使用'./kube-install.sh reset-etcd'重置etcd，然后使用'journalctl -ex'或'systemctl status etcd'或'tail -f /var/log/messages'查看状态和日志并解决错误"
}

start_etcd_cluster() {
  start_etcd
  i=0
  while [ $i -lt ${#ETCD_IPP[@]} ] 
  do
    ssh root@${ETCD_IPP[$i]} <<remotessh
      ./kube-install.sh start-etcd
    exit
remotessh
    let i++  
  done
}

# 重置etcd服务，若遇见etcd无法启动，可先重置etcd，再修改配置，启动etcd
reset_etcd() {
  print_time_and_string "重置etcd服务"
  print_time_and_string "关闭etcd服务"
  systemctl stop etcd
  print_time_and_string "删除etcd工作目录"
  rm -Rf /var/lib/etcd
  rm -Rf /var/lib/etcd-cluster
  print_time_and_string "创建etcd工作目录"
  mkdir -p /var/lib/etcd
  print_time_and_string "重置后修改etcd配置，可使用'./kube-install.sh start-etcd'来启动etcd服务"
}

reset_etcd_cluster() {
  reset_etcd
  i=0
  while [ $i -lt ${#ETCD_IPP[@]} ] 
  do
    ssh root@${ETCD_IPP[$i]} <<remotessh
      ./kube-install.sh reset_etcd
    exit
remotessh
    let i++  
  done
}

# 验证etcd集群
validate_etcd() {
  etcdctl --endpoints=https://${ETCD_LISTEN_IP}:2379 --ca-file=/etc/kubernetes/ssl/ca.pem --cert-file=/etc/kubernetes/ssl/kubernetes.pem --key-file=/etc/kubernetes/ssl/kubernetes-key.pem cluster-health
}

# 安装k8s
install_k8s() {
  mkdir -p /root/k8s/rpm
  mv 1.9.0/* /root/k8s/rpm/
  yum install /root/k8s/rpm/*.rpm -y
}

case "$1" in
  "init")
    init
    ;;
  "init-cluster")
    init_cluster
    ;;
  "install-docker")
    install_docker
    ;;
  "nodes-install-docker")
   nodes_install_docker
   ;;
  "install-cfssl")
    install_cfssl
    ;;
  "generate-ca")
    cfssl_generate_all_file
    ;;
  "distribute-ca")
    distribute_ca
    ;;
  "install-cfssl-gd-ca")
    install_cfssl
    cfssl_generate_all_file
    distribute_ca
    ;;
  "install-kubectl")
    install_kubectl
    ;;
  "generate-tls-token-kubeconfig")
    generate_tls_token_kubeconfig
    ;;
  "distribute-kubeconfig")
    distribute_kubeconfig
    ;;
  "install-etcd")
    install_etcd
    ;;
  "install-etcd-cluster")
    install_etcd_cluster
    ;;
  "start-etcd")
    start_etcd
    ;;
  "start-etcd-cluster")
    start_etcd_cluster
    ;;
  "reset-etcd")
    reset_etcd
    ;;
  "reset-etcd-cluster")
    reset_etcd_cluster
    ;;
  "validate-etcd")
    validate_etcd
    ;;
  "scp-shell")
    distribute_shell
    ;;
  "ssh-no-pwd")
    ssh_no_pwd
    ;;
  *)
    echo "Fuck You!"
    ;;
esac
