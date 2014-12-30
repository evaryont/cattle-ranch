sftp_server = nil
%w[/usr/lib/openssh/sftp-server
   /usr/libexec/openssh/sftp-server
   /usr/lib/ssh/sftp-server].each do |sftpbin|
  if File.exist? sftpbin
    sftp_server = sftpbin
    return
  end
end

node.default['sshd']['sshd_config']['Subsystem'] = "sftp #{sftp_server}"

openssh_server node['sshd']['config_file']
