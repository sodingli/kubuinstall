/bin/sh
#Create by sodingli
#refer docker  isntall document for centos :https://docs.docker.com/install/linux/docker-ce/centos/

sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine


yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


yum-config-manager --enable docker-ce-nightly
yum-config-manager --enable docker-ce-test
yum-config-manager --disable docker-ce-nightly

#安装特点版本yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
yum install docker-ce docker-ce-cli containerd.io
yum list docker-ce --showduplicates | sort -r
systemctl start docker
