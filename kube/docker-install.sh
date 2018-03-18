#!/bin/bash
# install docker

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] yum install docker
yum install -y docker

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] edit /usr/lib/systemd/system/docker.service
sed -i "s/[Service]/[Service]\nEnvironmentFile=-\/run\/flannel\/docker\nEnvironmentFile=-\/run\/docker_opts.env\nEnvironmentFile=-\/run\/flannel\/subnet.env\nEnvironmentFile=-\/run\/docker_opts.env/g" /usr/lib/systemd/system/docker.service
