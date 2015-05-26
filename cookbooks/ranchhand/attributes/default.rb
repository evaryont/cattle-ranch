node.default['ranchhand']['is_gigabit'] = true
node.default['ranchhand']['mosh'] = false

# If the node has a 'real' IPv6 address, not just loopback
if node['ip6addresss'] && node['ip6addresss'] != '::1'
  node.default['ranchhand']['ipv6'] = true
else
  node.default['ranchhand']['ipv6'] = false
  node.override['iptables-ng']['enabled_ip_versions'] = [4]
  node.override['network']['ipv6']['enable'] = false
end
