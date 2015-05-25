include_recipe 'sysctl::default'

file '/etc/sysctl.d/99-chef-attributes.conf' do
  content <<-EOSYSCTL
# #{node['config_disclaimer']}

fs.suid_dumpable=0
kernel.randomize_va_space=2
kernel.sysrq=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.shared_media=1
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.default.shared_media=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.icmp_ratelimit=100
net.ipv4.icmp_ratemask=88089
net.ipv4.ip_forward=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.all.forwarding=0
net.ipv6.conf.default.accept_ra_defrtr=0
net.ipv6.conf.default.accept_ra_pinfo=0
net.ipv6.conf.default.accept_ra_rtr_pref=0
net.ipv6.conf.default.accept_redirects=0
net.ipv6.conf.default.autoconf=0
net.ipv6.conf.default.dad_transmits=0
net.ipv6.conf.default.max_addresses=1
net.ipv6.conf.default.router_solicitations=0

# protect against tcp time-wait assassination hazards
# drop RST packets for sockets in the time-wait state
# (not widely supported outside of linux, but conforms to RFC)
net.ipv4.tcp_rfc1337=1

# TCP SYN cookie protection
# helps protect against SYN flood attacks
# only kicks in when net.ipv4.tcp_max_syn_backlog is reached
net.ipv4.tcp_syncookies=1

# tcp timestamps
# + protect against wrapping sequence numbers (at gigabit speeds)
# + round trip time calculation implemented in TCP
# - causes extra overhead and allows uptime detection by scanners like nmap
# enable @ gigabit speeds
net.ipv4.tcp_timestamps=#{(node['ranchhand']['is_gigabit'] ? 1 : 0)}

# Preventing link TOCTOU vulnerabilities
fs.protected_hardlinks=1
fs.protected_symlinks=1

# limit dmesg to root only
kernel.dmesg_restrict=1

# hide kernel symbol addresses in /proc/kallsyms from regular users
# without CAP_SYSLOG
kernel.kptr_restrict=1

# enables the kernels reverse path filtering mechanism, which will
# do source validation of the packet's received from all the interfaces on the machine
# protects from attackers that are using ip spoofing methods to do harm
net.ipv4.conf.all.rp_filter=1
net.ipv6.conf.all.rp_filter=#{File.exists?('/proc/sys/net/ipv6/conf/all/rp_filter') ? 1 : 0}
EOSYSCTL
  owner 'root'
  group 'root'
  mode '0644'

  notifies :start, 'service[procps]', :immediately
end
