#! /bin/sh

if [ ! -f "./bin/consul" ];then
    echo './bin/consul not found !'
    exit 0
fi

chown root:root ./bin/consul
cp ./bin/consul /usr/local/bin/
consul --version
consul -autocomplete-install
complete -C /usr/local/bin/consul consul
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir --parents /opt/consul
chown --recursive consul:consul /opt/consul
mkdir --parents /etc/consul.d

cp ./config/consul.service /etc/systemd/system/

cp ./config/consul.hcl /etc/consul.d/
chmod 640 /etc/consul.d/consul.hcl

cp ./config/client.hcl /etc/consul.d/
chmod 640 /etc/consul.d/client.hcl

chown --recursive consul:consul /etc/consul.d

systemctl enable consul


yum install -y yum-utils  device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce-3:19.03.6-3.el7.x86_64
systemctl enable docker
systemctl start docker
