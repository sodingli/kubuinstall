#!/bin/bash
# This script describes where to download the official released binaries needed
# It's suggested to download the entire *.tar.gz at https://pan.baidu.com/s/1c4RFaA

# example releases
K8S_VER=v1.13.4
ETCD_VER=v3.3.8
DOCKER_VER=18.09.2
CNI_VER=v0.7.5
DOCKER_COMPOSE=1.18.0
HARBOR=v1.5.4

echo  -e "\nNote1: Before this script, please finish downloading binaries manually from following urls."
echo -e "\nNote2：If binaries are not ready, use 'Ctrl + C' to stop this script."

echo -e "\n----download k8s binary at:"
echo -e https://dl.k8s.io/${K8S_VER}/kubernetes-server-linux-amd64.tar.gz

echo -e "\n----download etcd binary at:"
echo -e https://github.com/coreos/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
echo -e https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz

echo -e "\n----download docker binary at:"
echo -e https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER}.tgz

echo -e "\n----download ca tools at:"
echo -e https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
echo -e https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
echo -e https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

echo -e "\n----download docker-compose at:"
echo -e https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-Linux-x86_64

echo -e "\n----download harbor-offline-installer at:"
echo -e https://storage.googleapis.com/harbor-releases/harbor-offline-installer-${HARBOR}.tgz

echo -e "\n----download cni plugins at:"
echo -e https://github.com/containernetworking/plugins/releases

sleep 1

### prepare 'cfssl' cert tool suit
echo -e "\nMoving 'cfssl' to 'bin' dir..."
if [ -f "cfssl_linux-amd64" ]; then
  mv -f cfssl_linux-amd64 ../bin/cfssl
else
  echo -e Please download 'cfssl' at 'https://pkg.cfssl.org/R1.2/cfssl_linux-amd64'
fi
if [ -f "cfssljson_linux-amd64" ]; then
  mv -f cfssljson_linux-amd64 ../bin/cfssljson
else
  echo -e Please download 'cfssljson' at 'https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64'
fi
if [ -f "cfssl-certinfo_linux-amd64" ]; then
  mv -f cfssl-certinfo_linux-amd64 ../bin/cfssl-certinfo
else
  echo -e Please download 'cfssl-certinfo' at 'https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64'
fi

### prepare 'etcd' binaries
if [ -f "etcd-${ETCD_VER}-linux-amd64.tar.gz" ]; then
  echo -e "\nextracting etcd binaries..."
  tar zxf etcd-${ETCD_VER}-linux-amd64.tar.gz
  mv -f etcd-${ETCD_VER}-linux-amd64/etcd* ../bin
else
  echo -e Please download 'etcd-${ETCD_VER}-linux-amd64.tar.gz' first
fi

### prepare kubernetes binaries
if [ -f "kubernetes-server-linux-amd64.tar.gz" ]; then
  echo -e "\nextracting kubernetes binaries..."
  tar zxf kubernetes-server-linux-amd64.tar.gz
  mv -f kubernetes/server/bin/kube-apiserver ../bin
  mv -f kubernetes/server/bin/kube-controller-manager ../bin
  mv -f kubernetes/server/bin/kubectl ../bin
  mv -f kubernetes/server/bin/kubelet ../bin
  mv -f kubernetes/server/bin/kube-proxy ../bin
  mv -f kubernetes/server/bin/kube-scheduler ../bin
else
  echo -e Please download 'kubernetes-server-linux-amd64.tar.gz' first
fi

### prepare docker binaries
if [ -f "docker-${DOCKER_VER}.tgz" ]; then
  echo -e "\nextracting docker binaries..."
  tar zxf docker-${DOCKER_VER}.tgz
  mv -f docker/docker* ../bin
  if [ -f "docker/completion/bash/docker" ]; then
    mv -f docker/completion/bash/docker ../roles/docker/files/docker
  fi
else
  echo -e Please download 'docker-${DOCKER_VER}.tgz' first
fi

### prepare cni plugins, needed by flannel;
if [ -f "cni-${CNI_VER}.tgz" ]; then
  echo -e "\nextracting cni plugins binaries..."
  tar zxf cni-${CNI_VER}.tgz
  mv -f bridge ../bin
  mv -f flannel ../bin
  mv -f host-local ../bin
  mv -f loopback ../bin
  mv -f portmap ../bin
else
  echo -e Please download 'cni-${CNI_VER}.tgz' first
fi
