#!/bin/bash
# start docker

systemctl stop docker
systemctl enable docker
systemctl start docker
