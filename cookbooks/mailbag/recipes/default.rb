include_recipe 'lvm'
include_recipe 'filesystem'

encrypted_blockdevice 'datacrypt' do
  size 7168
  keystore 'encrypted_databag'
  file '/var/mailbag.fs'
end
filesystem 'datacrypt' do
  size '7168'
  fstype 'ext4' 
  mount '/opt/mailbag' # where to mount the encrypted filesystem onto the host
  file '/var/mailbag.fs' # location of where the encrypted filesystem image will go
  device '/dev/loop7' # not sure what this actually does...
end

include_recipe 'mailbag::smtp'
include_recipe 'mailbag::imap'
