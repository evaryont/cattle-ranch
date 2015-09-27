##include_recipe 'lvm'
##include_recipe 'filesystem'
##
### This is where mail will be stored
##directory '/opt/mailbag'
##
### Create an encrypted filesystem that will store the mail
##encrypted_blockdevice 'datacrypt' do
##  size 7168
##  keystore 'encrypted_databag'
##  file '/var/mailbag.fs'
##end
##filesystem 'datacrypt' do
##  size '7168'
##  fstype 'ext4' 
##  mount '/opt/mailbag'
##  file '/var/mailbag.fs' # location of where the encrypted filesystem image will go
##  device '/dev/loop7' # not sure what this actually does...
##end

user 'boss' do
  comment 'Receptor of administrivia'
  shell '/usr/sbin/nologin'
end

# Setup the servers
include_recipe 'mailbag::amavis'
include_recipe 'mailbag::smtp'
include_recipe 'mailbag::imap'

# Expose the ports to the internet
iptables_ng_rule '51-smtp' do
  chain 'INPUT'
  rule '--protocol tcp --dport 25 --match state --state NEW --jump ACCEPT'
end
iptables_ng_rule '52-smtp-submission' do
  chain 'INPUT'
  rule '--protocol tcp --dport 465 --match state --state NEW --jump ACCEPT'
end
iptables_ng_rule '53-imap' do
  chain 'INPUT'
  rule '--protocol tcp --dport 993 --match state --state NEW --jump ACCEPT'
end
iptables_ng_rule '53-managesieve' do
  chain 'INPUT'
  rule '--protocol tcp --dport 4190 --match state --state NEW --jump ACCEPT'
end
