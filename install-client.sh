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

cp consul.service /etc/systemd/system/

cp ./config/consul.hcl /etc/consul.d/
chmod 640 /etc/consul.d/consul.hcl

cp ./config/client.hcl /etc/consul.d/
chmod 640 /etc/consul.d/client.hcl

systemctl enable consul
