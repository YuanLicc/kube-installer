#!/bin/bash
# install cfssl
if [ ! -f "/usr/local/bin/cfssl" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl is not found, download cfssl_linux-amd64 from https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
  wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
  
  if [ ! -f "cfssl_linux-amd64" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi
  
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod dowmload file cfssl_linux-amd64
  chmod +x cfssl_linux-amd64
  
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move file cfssl_linux-amd64 to /usr/local/bin/cfssl
  mv cfssl_linux-amd64 /usr/local/bin/cfssl
else 
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl is exit
fi

if [ ! -f "/usr/local/bin/cfssljson" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssljson is not found, download cfssljson_linux-amd64 from https://pkg.cfssl.org/R1.2/cfssljson_linxu-amd64
  wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
  
  if [ ! -f "cfssljson_linux-amd64" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi

  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod download file cfssljson_linux-amd64
  chmod +x cfssljson_linux-amd64
  
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move file cfssljson_linux-amd64 to /usr/local/bin/cfssljson
  mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssljson is exit
fi

if [ ! -f "/usr/local/bin/cfssl-certinfo" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl-certinfo is not found, download cfssl-certinfo_linux-amd64 from https://pkg.cfssl.org/cfssl-certinfo-amd64
  wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
  
  if [ ! -f "cfssl-certinfo_linux-amd64" ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [WARNING] download installer package faild
    exit 1
  fi

  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] chmod download file cfssl-certinfo_linux-amd64
  chmod +x cfssl-certinfo_linux-amd64
  
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] move file cfssl-certinfo_linux-amd64 to /usr/local/bin/cfssl-certinfo
  mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl-certinfo is exit
fi

if [[ $PATH =~ "/usr/local/bin" ]]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] /usr/local/bin is in the $PATH
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] copy $PATH to $PATH_TMP
  export PATH_TMP=$PATH
  
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] add /usr/local/bin to $PATH
  export PATH=/usr/local/bin:$PATH
fi

if [ ! -d "/root/ssl/" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /root/ssl is not found, create fir /root/ssl/
  mkdir /root/ssl
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] dir /root/ssl is exit
fi

if [ -f "/root/ssl/config.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/config.json is exit,delete it
  chmod +x /root/ssl/config.json
  rm -f /root/ssl/config.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] print default cfssl config file to /root/ssl/config.json
cfssl print-defaults config > /root/ssl/config.json

if [ -f "/root/ssl/csr.json" ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file /root/ssl/csr.json is exit,delete it
  chmod +x /root/ssl/csr.json
  rm -f /root/ssl/csr.json
fi

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] print default cfssl csr file to /root/ssl/csr.json
cfssl print-defaults csr > /root/ssl/csr.json

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] cfssl install successful!
