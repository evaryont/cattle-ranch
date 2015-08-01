node.default['ranchhand']['is_gigabit'] = true

# Protect against wrapping sequence numbers at gigabit speeds
node.override['sysctl']['params']['net']['ipv4']['tcp_timestamps'] =
  (node['ranchhand']['is_gigabit'] ? 1 : 0)
# Preventing link TOCTOU vulnerabilities
node.override['sysctl']['params']['fs']['protected_hardlinks'] = 1
node.override['sysctl']['params']['fs']['protected_symlinks'] = 1
# limit dmesg to root only
node.override['sysctl']['params']['kernel']['dmesg_restrict'] = 1
# hide kernel symbol addresses in /proc/kallsyms from regular users
# without CAP_SYSLOG
node.override['sysctl']['params']['kernel']['kptr_restrict'] = 1

# If the node has a 'real' IPv6 address, not just loopback
if node['ip6addresss'] && node['ip6addresss'] != '::1'
  node.default['ranchhand']['ipv6'] = true
else
  node.default['ranchhand']['ipv6'] = false
  node.override['iptables-ng']['enabled_ip_versions'] = [4]
  node.override['network']['ipv6']['enable'] = false
end

if node['platform_family'] == 'debian'
  node.default['ranchhand']['extra_packages'] = %w(git-doc vim-nox aptitude)

elsif node['platform'] == 'arch'
  node.default['ranchhand']['extra_packages'] = %w(vim vim-runtime the_silver_searcher)

  node.override['sysctl']['conf_dir'] = '/etc/sysctl.d'
  node.override['sysctl']['conf_file'] = File.join(node['sysctl']['conf_dir'], '/99-chef-attributes.conf')
  node.override['sshd']['package'] = 'openssh'
  node.override['ntp']['packages'] = %w(ntp)
end

node.default['ranchhand']['mosh'] = false
node.default['ranchhand']['httpd'] = nil
node.default['ranchhand']['admin_name'] = 'colin'
node.default['ranchhand']['dotfiles_sync'] = true
node.default['ranchhand']['https_only'] = false
node.default['ranchhand']['ssh_port'] = 22
node.default['ranchhand']['public_direct_ssh'] = true
node.default['ranchhand']['domain_name'] = 'evaryont.me'

node.default['ranchhand']['openssl_dev'] = case node['platform_family']
                                           when 'redhat', 'fedora'
                                             'openssl-devel'
                                           when 'debian'
                                             'libssl-dev'
                                           end
