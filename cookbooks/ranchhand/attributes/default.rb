node.default['ranchhand']['is_gigabit'] = true
node.default['ranchhand']['mosh'] = false

if node['ip6addresss']
  node.default['ranchhand']['ipv6'] = true
else
  node.default['ranchhand']['ipv6'] = false
  node.override['iptables-ng']['enabled_ip_versions'] = [4]
  node.override['network']['ipv6']['enable'] = false
end
