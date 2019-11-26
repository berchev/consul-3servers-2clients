#!/usr/bin/env bash

set -x
#############################
# Functions definition #
#############################

# Verify/Fix file ownership function. $1 means -> Accept 1 argument (target file)
funcOwnership()
{
	[ "$(stat -c "%U %G" $1)" == "consul consul" ] || {
           chown -R consul.consul $1
        }
}

# Verify/Fix file permissions. $1 means -> Accept 1 argument (target file)
funcPermissions()
{
    [ "$(stat -c "%a" $1)" == "640" ] || {
        chmod 640 $1
    }
}

##############################
# Variables definition start #
##############################

# Specify the product you would like to install
P=consul

# Specify consul configuration directory
consul_config_dir="/etc/consul.d"

# Specify consul data directory 
consul_data_dir="/opt/consul"

#####################
# Main script start #
#####################

# Installing the latest version of the specified product
VERSION=$(curl -sL https://releases.hashicorp.com/${P}/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'ent|beta|rc|alpha' | tail -n1)
    
# Determine your arch
if [[ "`uname -m`" =~ "arm" ]]; then
  ARCH=arm
else
  ARCH=amd64
fi

wget -q -O /tmp/${P}.zip https://releases.hashicorp.com/${P}/${VERSION}/${P}_${VERSION}_linux_${ARCH}.zip
unzip -o -d /usr/local/bin /tmp/${P}.zip
rm /tmp/${P}.zip

# Add non-priviliged system user to run consul, if not added
getent passwd consul || {
  useradd --system --home ${consul_config_dir} --shell /bin/false consul
}

# Add consul data directory, if not added
[ -d ${consul_data_dir} ] || {
  mkdir --parents ${consul_data_dir}
}

# Verify ownership of data directory and fix if needed
funcOwnership ${consul_data_dir}

# Create consul configuration directory if not created
[ -d ${consul_config_dir} ] || {
  mkdir --parents ${consul_config_dir}
}

# Verify the ownership of consul configuration directory and fix if needed
funcOwnership ${consul_config_dir}

# Add basic consul configuration, if not added
# Note that this configuration is using ENV variables from vagrant
[ -f ${consul_config_dir}/consul_server.json ] || {
cat << EOF > ${consul_config_dir}/consul_server.json
{
    "bind_addr": "${ip_server}",
    "datacenter": "dc1",
    "data_dir": "${consul_data_dir}",
    "log_level": "INFO",
    "enable_syslog": true,
    "enable_debug": true,
    "node_name": "${node_name}",
    "server": true,
    "client_addr": "0.0.0.0",
    "bootstrap_expect": 3,
    "rejoin_after_leave": true,
    "ui": true,
    "retry_join": ["${ip_server2}"]
}
EOF
}

# Verify the ownership of main consul configuration (consul_server.json) and fix if needed
funcOwnership ${consul_config_dir}/consul_server.json

# Verify the permissions of main consul configuration (consul_server.json) and fix if needed
funcPermissions ${consul_config_dir}/consul_server.json

# Add consul target into systemd, if not added
[ -f /etc/systemd/system/consul.service ] || {
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionDirectoryNotEmpty=${consul_config_dir}/

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=${consul_config_dir}/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
systemctl enable consul
systemctl start consul
}