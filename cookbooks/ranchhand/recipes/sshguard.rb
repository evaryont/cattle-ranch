package 'sshguard' do
  action :install
end

service 'sshguard' do
  supports status: true, start: true, stop: true, restart: true
  action [:enable, :start]
end

iptables_ng_rule '39-sshguard' do
  chain 'INPUT'
  rule '-j SSHGUARD'
end
