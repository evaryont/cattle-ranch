include_recipe 'lvm'
include_recipe 'filesystem'

# This is where mail will be stored
directory '/opt/mailbag'

# Create an encrypted filesystem that will store the mail
encrypted_blockdevice 'datacrypt' do
  size 7168
  keystore 'encrypted_databag'
  file '/var/mailbag.fs'
end
filesystem 'datacrypt' do
  size '7168'
  fstype 'ext4' 
  mount '/opt/mailbag'
  file '/var/mailbag.fs' # location of where the encrypted filesystem image will go
  device '/dev/loop7' # not sure what this actually does...
end

# Setup the servers
include_recipe 'mailbag::amavis'
include_recipe 'mailbag::smtp'
include_recipe 'mailbag::imap'
