# Grab the ssh version (like 6.6.1p1, or 5.3p3). Commonly seen SSH versions:
#  - 6.7 on Arch
#  - 6.6 on Ubuntu 14.04
#  - 5.9 on Ubuntu 12.04
#  - 5.3 on Ubuntu 10.04, CentOS 6
ssh_version = `ssh -V 2>&1`.sub(/^OpenSSH_([\d.p]+)[, ].*/m, '\1')

Chef::Log.debug "Running ssh version #{ssh_version}!"

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
node.default['sshd']['sshd_config']['Subsystem'] = "sftp #{sftp_server}"

# Since 6.0, openssh has a stronger privilege separation using Linux's seccomp
# mechanism.
if ssh_version =~ /^6/
   node.default['sshd']['sshd_config']['UsePrivilegeSeparation'] = 'sandbox'
else
   # Otherwise use the same ol' isolated child processes
   node.default['sshd']['sshd_config']['UsePrivilegeSeparation'] = 'yes'
end

host_keys = Dir['/etc/ssh/ssh_host_*']
#/etc/ssh/ssh_host_ed25519_key   /etc/ssh/ssh_host_rsa_key"
#    "sshd": {
#      "sshd_config": {
#        "HostKey": [ "/etc/ssh/ssh_host_ed25519_key", "/etc/ssh/ssh_host_rsa_key" ]

# Old SSH protocol 2 keys
%w(dsa ecdsa).each do |keytype|
   file "/etc/ssh_host_#{keytype}_key" do
      action :delete
   end
   file "/etc/ssh_host_#{keytype}_key.pub" do
      action :delete
   end
end

# And delete SSH protocol 1 keys
file "/etc/ssh_host_key" do
   action :delete
end
file "/etc/ssh_host_key.pub" do
   action :delete
end

if node['hostname'] == 'vagabond'
   # This looks like the virtual machine I use with vagrant to test the configs.
   # Let vagrant ssh log in, too
   node.override['sshd']['sshd_config']['AllowUsers'] = node['sshd']['sshd_config']['AllowUsers']+' vagrant'
end

include_recipe 'sshd::install'
openssh_server node['sshd']['config_file'] do
   action :create
end
