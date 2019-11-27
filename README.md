# consul-3servers-2clinets

## Repo description
This repo provides Vagrant development environment containing simple configuration of 3 Consul Servers and 2 Consul Clients. 
Some more details:
- Consul is configured as a systemd service.
- There is configured non-priviliged user called **consul**, which purpose is to run consul.
- All 3 servers are configured with bootstrap enabled.
- Both clients have simple [web service](https://github.com/berchev/consul-3servers-2clients/blob/master/scripts/client_service.sh) enabled 
- All nodes have syslog logging enabled
- All nodes have configured data directory and configuration directory
- All nodes are with included gossip encryption.

For more details related to Consul Server/Client configuration, you can check [server_provision.sh](https://github.com/berchev/consul-3servers-2clients/blob/master/scripts/server_provision.sh) and [client_provision.sh](https://github.com/berchev/consul-3servers-2clients/blob/master/scripts/client_provision.sh) scripts.

This project can be used as a fundametal step for other consul related project.

## Requirements
- VirtualBox installed
- Hashicorp Vagrant installed

## How to use this project
- clone the repo 
- change to repo directory
- start provisioning of vagrant environment
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant up
```
- verify that all servers and client are in running status
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant status
Current machine states:

consul-server1            running (virtualbox)
consul-server2            running (virtualbox)
consul-server3            running (virtualbox)
consul-client1            running (virtualbox)
consul-client2            running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ 
```
- shh to node by your choice (for example: consul-server1)
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant ssh consul-server1
```
- reach the web UI and walk through different menus, by visiting URL below
```
http://192.168.10.11:8500/
```
- in case you do not need the project anymore
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant destroy -f
```

## TODO
- [ ] Secure Agent Communication with TLS Encryption
