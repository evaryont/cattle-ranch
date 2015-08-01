# Allow SSH through the firewall. If node['ranchhand']['public_direct_ssh'] is
# set to false, SSH's port is blocked instead and you should rely on some sort
# of other method to get in. Like sslh!
ssh_iptables_target = (node['ranchhand']['public_direct_ssh'] ? 'ACCEPT' : 'DROP')
iptables_ng_rule '40-ssh' do
  chain 'INPUT'
  rule "--protocol tcp --dport #{node['ranchhand']['ssh_port']} --match state --state NEW --jump #{ssh_iptables_target}"
end

# This is a slight improvement, even for older versions
cookbook_file 'openssh moduli replacement' do
  path '/etc/ssh/moduli'
  source 'moduli'
  mode '0644'
end

node.default['sshd']['sshd_config']['Port'] = node['ranchhand']['ssh_port']
node.default['sshd']['sshd_config']['ListenAddress'] = (node['ranchhand']['public_direct_ssh'] ? '::' : '::1')

# Grab the ssh version (like 6.6.1p1, or 5.3p3). Commonly seen SSH versions:
#  - 6.9 on Arch
#  - 6.0 on Debian 7
#  - 6.6 on Ubuntu 14.04
#  - 5.9 on Ubuntu 12.04
#  - 5.3 on Ubuntu 10.04, CentOS 6
#
# See also ranchhand::backports to upgrade some distros
ssh_version = Gem::Version.new(`ssh -V 2>&1`.sub(/^OpenSSH_([\d.p]+)[, ].*/m, '\1').split('p')[0])

# Bail on SSH versions less than 6
if ssh_version < Gem::Version.new("6")
  Chef::Log.warn "NOPE! Your SSH is TOO OLD. Get version 6 at least (was: #{ssh_version})"
  return
end

Chef::Log.debug "Running ssh version #{ssh_version}!"

# Try finding the sftp binary in various locations. Arch puts it in a directory
# that the original sshd cookbook doesn't consider.
sftp_server = nil
%w[/usr/lib/openssh/sftp-server
   /usr/libexec/openssh/sftp-server
   /usr/lib/ssh/sftp-server].each do |sftpbin|
  if File.exist? sftpbin
    sftp_server = sftpbin
    break
  end
end

Chef::Log.debug "SFTP binary found: #{sftp_server}"
node.default['sshd']['sshd_config']['Subsystem'] = sftp_server ? "sftp #{sftp_server}" : nil

# Since 6.0, OpenSSH has a stronger privilege separation using Linux's seccomp
# mechanism.
node.default['sshd']['sshd_config']['UsePrivilegeSeparation'] = 'sandbox'

# Since 6.5, OpenSSH supports the Ed25519 curve as a public key type.
if ssh_version >= Gem::Version.new("6.5")
  Chef::Log.info "OpenSSH supports Ed25519 keys!"
  node.override['sshd']['sshd_config']['HostKey'] = ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key']
  @ed22519_key = true
else
  Chef::Log.warn "OpenSSH: No support for Ed25519 keys."
  # older versions though, will break. So don't break them, and only use RSA.
  node.override['sshd']['sshd_config']['HostKey'] = ['/etc/ssh/ssh_host_rsa_key']
  @ed22519_key = false
end

# Delete old SSH protocol 2 keys
%w(dsa ecdsa).each do |keytype|
  file "/etc/ssh/ssh_host_#{keytype}_key" do
    action :delete
  end
  file "/etc/ssh/ssh_host_#{keytype}_key.pub" do
    action :delete
  end
end

# And delete SSH protocol 1 keys
file "/etc/ssh/ssh_host_key" do
  action :delete
end
file "/etc/ssh/ssh_host_key.pub" do
  action :delete
end

if @ed22519_key
  execute 'generate Ed25519 host keys' do
     command <<-EOBASH
ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key < /dev/null
EOBASH
     cwd '/etc/ssh'
     creates '/etc/ssh/ssh_host_ed25519_key'
     notifies :restart, "service[#{node['sshd']['service_name']}]"
  end
end

execute 'generate RSA 4096 host keys' do
  command <<-EOBASH
ssh-keygen -t rsa -b 4096 -P "" -f /etc/ssh/ssh_host_rsa_key < /dev/null
EOBASH
  cwd '/etc/ssh'
  creates '/etc/ssh/ssh_host_rsa_key'
  notifies :restart, "service[#{node['sshd']['service_name']}]"
end

# This is the list of key exchange protocols, ciphers, and MAC functions that I trust are of decent security
key_exchanges = ["curve25519-sha256@libssh.org","diffie-hellman-group-exchange-sha256"]
ciphers = ["chacha20-poly1305@openssh.com","aes256-gcm@openssh.com","aes128-gcm@openssh.com","aes256-ctr","aes192-ctr","aes128-ctr"]
macs = ["hmac-sha2-512-etm@openssh.com","hmac-sha2-256-etm@openssh.com","hmac-ripemd160-etm@openssh.com","umac-128-etm@openssh.com","hmac-sha2-512","hmac-sha2-256","hmac-ripemd160","umac-128@openssh.com"]

# Then, get a list of every one the SSH server supports, find the intersection
# of crypto that is in my trusted list, and configure the sshd configuration to
# use that set.
node.override['sshd']['sshd_config']['KexAlgorithms'] = (key_exchanges & `ssh -Q kex`.split("\n").map(&:strip)).join(',')
node.override['sshd']['sshd_config']['Ciphers'] = (ciphers & `ssh -Q cipher`.split("\n").map(&:strip)).join(',')
node.override['sshd']['sshd_config']['MACs'] = (macs & `ssh -Q mac`.split("\n").map(&:strip)).join(',')

# This is a list of all users that I allow to SSH into the server. They are all
# part of the 'sshing' group
allowed_users = (node['etc']['group']['sshing'] ? node['etc']['group']['sshing'].to_hash['members'] : [])

if node['hostname'] == 'vagabond'
  # This looks like the virtual machine I use with vagrant to test the configs.
  # Let vagrant ssh in, too
  allowed_users << 'vagrant'
end

# Make sure the admin user is allowed access
allowed_users << node['ranchhand']['admin_name']

# Clean up the list, make sure there is no duplicates...
allowed_users.sort!
allowed_users.uniq!

# Ensure the 'sshing' group exists. These are the users that can use SSH. If you
# are part of the group, everything is OK.
group 'sshing' do
  action :create
  append false
  excluded_members ['root']
  members allowed_users
end

node.override['sshd']['sshd_config']['AllowUsers'] = allowed_users.join(' ')

include_recipe 'sshd::install'
openssh_server node['sshd']['config_file'] do
  action :create
end

include_recipe 'ranchhand::sshguard'

# Do a bit of detection based on platform family
if debian? or ubuntu?
  node.override['mosh']['use_ppa'] = true
elsif rhel? or fedora?
  node.override['mosh']['use_epel'] = true
end
include_recipe 'mosh::default' if node['ranchhand']['mosh']

# Delete a bunch of the sshrc files. I want to ensure that it is never allowed
# to execute
node['sshd']['sshd_config']['AllowUsers'].split(' ').each do |user|
  file "#{node['etc']['passwd'][user]['dir']}/.ssh/rc" do
    mode '0600'
    action :delete
  end
end
file "/etc/ssh/rc" do
   action :delete
end
