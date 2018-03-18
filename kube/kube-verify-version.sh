# check kube version
if [ $KUBE_VERSION ]; then
  if [ ! -z $KUBE_VERSION ]; then
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kubernetes version : $KUBE_VERSION
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kubernetes version is not found, set default version : v1.6.0
    export KUBE_VERSION="v1.6.0"
  fi
else
  echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] kubernetes version is not found, set default version : v1.6.0
  export KUBE_VERSION="v1.6.0"
fi
