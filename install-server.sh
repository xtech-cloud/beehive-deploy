#! /bin/sh

if [ ! -d "./bin/consul" ];then
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
chown --recursive consul:consul /etc/consul.d

cp ./config/consul.service /etc/systemd/system/

cp ./config/consul.hcl /etc/consul.d/
chmod 640 /etc/consul.d/consul.hcl

cp ./config/server.hcl /etc/consul.d/
chmod 640 /etc/consul.d/server.hcl

systemctl enable consul
