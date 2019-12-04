# Any single server details
server = [
  { hostname: "consul-server1", ip: "192.168.10.11", port: 8501, box: "berchev/xenial64", tls_port: 8551 },
  { hostname: "consul-server2", ip: "192.168.10.12", port: 8502, box: "berchev/xenial64", tls_port: 8552 },
  { hostname: "consul-server3", ip: "192.168.10.13", port: 8503, box: "berchev/xenial64", tls_port: 8553 }
]

# Any single clinet details
client = [
  { hostname: "consul-client1", ip: "192.168.10.21", box: "berchev/nginx64", tls_port: 8551 },
  { hostname: "consul-client2", ip: "192.168.10.22", box: "berchev/nginx64", tls_port: 8551 }
]


# Provision of servers and clinets using above details
Vagrant.configure("2") do |config|
  server.each do |server|
    config.vm.define server[:hostname] do |node|
      node.vm.box = server[:box]
      node.vm.hostname = server[:hostname]
      node.vm.network "private_network", ip: server[:ip]
      node.vm.provision :shell, path: "scripts/server_provision.sh", env: { "ip_server" => server[:ip], "node_name" => server[:hostname], "ip_server2" => "192.168.10.11", "tls_port" => server[:tls_port] }
      node.vm.network :forwarded_port, guest: 8500, host: server[:port]
      node.vm.network :forwarded_port, guest: 8550, host: server[:tls_port]
    end
  end

  client.each do |client|
    config.vm.define client[:hostname] do |node|
      node.vm.box = client[:box]
      node.vm.hostname = client[:hostname]
      node.vm.network "private_network", ip: client[:ip]
      node.vm.provision :shell, path: "scripts/client_provision.sh", env: { "ip_client" => client[:ip], "node_name" => client[:hostname], "tls_port" => client[:tls_port] }
      node.vm.provision :shell, path: "scripts/client_service.sh"
    end
  end
end