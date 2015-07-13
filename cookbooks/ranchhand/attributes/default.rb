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

if node['platform_family'] == 'debian'
  node.default['ranchhand']['extra_packages'] = %w(git-doc vim-nox)

elsif node['platform'] == 'arch'
  node.default['ranchhand']['extra_packages'] = %w(vim vim-runtime the_silver_searcher)

  node.override['sysctl']['conf_dir'] = '/etc/sysctl.d'
  node.override['sysctl']['conf_file'] = File.join(node['sysctl']['conf_dir'], '/99-chef-attributes.conf')
  node.override['sshd']['package'] = 'openssh'
  node.override['ntp']['packages'] = %w(ntp)
end

node.default['ranchhand']['httpd'] = nil
