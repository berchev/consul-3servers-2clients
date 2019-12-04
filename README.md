# consul-3servers-2clients

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
- Connection between servers and clients has TLS encryption
- All needed CA, TLS/SSL certificates are generated with consul

For more details related to Consul Server/Client configuration, you can check [server_provision.sh](https://github.com/berchev/consul-3servers-2clients/blob/master/scripts/server_provision.sh) and [client_provision.sh](https://github.com/berchev/consul-3servers-2clients/blob/master/scripts/client_provision.sh) scripts.

This project can be used as a fundamental step for other consul related project.

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
- ssh to node consul-server1
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant ssh consul-server1
```

- change to /vagrant/certificate-authority and verify that TLS is working. The result should be error:
```
vagrant@consul-server1:/vagrant/certificate-authority$ consul members -http-addr="https://192.168.10.11:8551"
Error retrieving members: Get https://192.168.10.11:8551/v1/agent/members?segment=_all: x509: certificate signed by unknown authority
vagrant@consul-server1:/vagrant/certificate-authority$ 
```
- Stay on the same dir and now provide all needed certificates(CA public, Digital certificate public and private):
```
vagrant@consul-server1:/vagrant/certificate-authority$ consul members -ca-file=consul-agent-ca.pem -client-cert=tls-ssl-cli-ui/dc1-cli-consul-0.pem   -client-key=tls-ssl-cli-ui/dc1-cli-consul-0-key.pem -http-addr="https://192.168.10.11:8551"
Node            Address             Status  Type    Build  Protocol  DC   Segment
consul-server1  192.168.10.11:8301  alive   server  1.6.2  2         dc1  <all>
consul-server2  192.168.10.12:8301  alive   server  1.6.2  2         dc1  <all>
consul-server3  192.168.10.13:8301  alive   server  1.6.2  2         dc1  <all>
consul-client1  192.168.10.21:8301  alive   client  1.6.2  2         dc1  <default>
consul-client2  192.168.10.22:8301  alive   client  1.6.2  2         dc1  <default>
vagrant@consul-server1:/vagrant/certificate-authority$ 
```
- in case you do not need the project anymore
```
georgiman@MacBook-Machine consul-3servers-2clients (add-service) $ vagrant destroy -f
```

## Remark
You cannot reach the UI interface, unless you do the following:
- add `consul-agent-ca.pem` to your Keychain
- using openssl create `.p12` certificate from `dc1-cli-consul-0.pem` and `dc1-cli-consul-0-key.pem`
- Add the resulted `.p12` file to your Keychain
- For convenience I have added `certificate-authority/tls-ssl-cli-ui/certificate.p12` certificate ready for import

## TODO
- [x] Secure Agent Communication with TLS Encryption
