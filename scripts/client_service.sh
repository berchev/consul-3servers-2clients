#!/usr/bin/env bash

set -x

# Specify consul configuration directory
consul_config_dir="/etc/consul.d"

# If web service is not defined, define one
[ -f ${consul_config_dir}/web.json ] || {
cat << EOF > ${consul_config_dir}/web.json
{
    "service": {
        "name": "web",
        "tags": ["primary"],
        "port": 80,
        "check": {
            "http": "http://localhost:80",
            "interval": "10s"
        }
    }
}
EOF
}

# Reload with new configuration
systemctl enable consul
systemctl start consul