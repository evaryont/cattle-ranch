include_recipe 'sysctl::default'

## TCP hardening
#===============
# See https://wiki.archlinux.org/index.php/Sysctl#TCP.2FIP_stack_hardening for
# more information for various sysctls

# TCP SYN cookie protection
# helps protect against SYN flood attacks
# only kicks in when net.ipv4.tcp_max_syn_backlog is reached
sysctl_param 'net.ipv4.tcp_syncookies' do
  value 1
end

# protect against tcp time-wait assassination hazards
# drop RST packets for sockets in the time-wait state
# (not widely supported outside of linux, but conforms to RFC)
sysctl_param 'net.ipv4.tcp_rfc1337' do
  value 1
end

# enables the kernels reverse path filtering mechanism, which will
# do source validation of the packet's received from all the interfaces on the machine
# protects from attackers that are using ip spoofing methods to do harm
sysctl_param 'net.ipv4.conf.all.rp_filter' do
  value 1
end
sysctl_param 'net.ipv6.conf.all.rp_filter' do
  value 1
  only_if { File.exists? '/proc/sys/net/ipv6/conf/all/rp_filter' }
end

# tcp timestamps
# + protect against wrapping sequence numbers (at gigabit speeds)
# + round trip time calculation implemented in TCP
# - causes extra overhead and allows uptime detection by scanners like nmap
# enable @ gigabit speeds
sysctl_param 'net.ipv4.tcp_timestamps' do
  value (node['ranchhand']['is_gigabit'] ? 1 : 0)
end

# log martian packets
sysctl_param 'net.ipv4.conf.all.log_martians' do
  value 1
end

# ignore echo broadcast requests to prevent being part of smurf attacks (default)
sysctl_param 'net.ipv4.icmp_echo_ignore_broadcasts' do
  value 1
end

# ignore bogus icmp errors (default)
sysctl_param 'net.ipv4.icmp_ignore_bogus_error_responses' do
  value 1
end

# send redirects (not a router, disable it)
sysctl_param 'net.ipv4.conf.all.send_redirects' do
  value 0
end

# ICMP routing redirects (only secure)
%w(net.ipv4.conf.default.accept_redirects
   net.ipv4.conf.all.accept_redirects
   net.ipv6.conf.default.accept_redirects
   net.ipv6.conf.all.accept_redirects).each do |param|
  sysctl_param param do
    value 0
  end
end

## System hardening
#==================
# See https://wiki.archlinux.org/index.php/Security#Kernel_hardening for
# more information for various sysctls

# limit dmesg to root only
sysctl_param 'kernel.dmesg_restrict' do
  value 1
end

# hide kernel symbol addresses in /proc/kallsyms from regular users
# without CAP_SYSLOG
sysctl_param 'kernel.kptr_restrict' do
  value 1
end

# Preventing link TOCTOU vulnerabilities
sysctl_param 'fs.protected_hardlinks' do
  value 1
end
sysctl_param 'fs.protected_symlinks' do
  value 1
end
