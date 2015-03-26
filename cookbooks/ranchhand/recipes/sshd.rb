# Grab the ssh version (like 6.6.1p1, or 5.3p3). Commonly seen SSH versions:
#  - 6.7 on Arch
#  - 6.6 on Ubuntu 14.04
#  - 5.9 on Ubuntu 12.04
#  - 5.3 on Ubuntu 10.04, CentOS 6
ssh_version = Gem::Version.new(`ssh -V 2>&1`.sub(/^OpenSSH_([\d.p]+)[, ].*/m, '\1'))

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
else
   Chef::Log.warn "OpenSSH: No support for Ed25519 keys."
   # older versions though, will break. So don't break them, and only use RSA.
   node.override['sshd']['sshd_config']['HostKey'] = ['/etc/ssh/ssh_host_rsa_key']
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

execute 'generate Ed25519 host keys' do
   command <<-EOBASH
rm ssh_host_*key*
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
EOBASH
   cwd '/etc/ssh'
   creates '/etc/ssh/ssh_host_ed25519_key'
   notifies :restart, 'service[ssh]'
end

key_exchanges = ["curve25519-sha256@libssh.org","diffie-hellman-group-exchange-sha256"]
node.override['sshd']['sshd_config']['KexAlgorithms'] = (key_exchanges & `ssh -Q kex`.split("\n").map(&:strip)).join(',')

ciphers = ["chacha20-poly1305@openssh.com","aes256-gcm@openssh.com","aes128-gcm@openssh.com","aes256-ctr","aes192-ctr","aes128-ctr"]
node.override['sshd']['sshd_config']['Ciphers'] = (ciphers & `ssh -Q cipher`.split("\n").map(&:strip)).join(',')

macs = ["hmac-sha2-512-etm@openssh.com","hmac-sha2-256-etm@openssh.com","hmac-ripemd160-etm@openssh.com","umac-128-etm@openssh.com","hmac-sha2-512","hmac-sha2-256","hmac-ripemd160","umac-128@openssh.com"]
node.override['sshd']['sshd_config']['MACs'] = (macs & `ssh -Q mac`.split("\n").map(&:strip)).join(',')

if node['hostname'] == 'vagabond'
   # This looks like the virtual machine I use with vagrant to test the configs.
   # Let vagrant ssh in, too
   node.override['sshd']['sshd_config']['AllowUsers'] = node['sshd']['sshd_config']['AllowUsers']+' vagrant'
end

include_recipe 'sshd::install'
openssh_server node['sshd']['config_file'] do
   action :create
end

cookbook_file 'openssh moduli replacement' do
   path '/etc/ssh/moduli'
   source 'moduli'
   mode '0644'
end

iptables_ng_rule '40-ssh' do
  chain 'INPUT'
  rule '--protocol tcp --dport 22 --match state --state NEW --jump ACCEPT'
end

include_recipe 'ranchhand::sshguard'

# Do a bit of detection based on platform family
if debian? or ubuntu?
   node.override['mosh']['use_ppa'] = true
elsif rhel? or fedora?
   node.override['mosh']['use_epel'] = true
end
include_recipe 'mosh::default' if node['ranchhand']['mosh']
