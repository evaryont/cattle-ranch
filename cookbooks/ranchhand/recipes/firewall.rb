iptables_ng_rule '03-invalid-state' do
  chain 'INPUT'
  rule '-m state --state INVALID -j INVDROP'
end

iptables_ng_rule '03 tcp flags FIN,SYN,RST,PSH,ACK,URG NONE' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j INVDROP'
end

iptables_ng_rule '03 tcp flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j INVDROP'
end

iptables_ng_rule '03 tcp flags FIN,SYN FIN,SYN' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j INVDROP'
end

iptables_ng_rule '03 tcp flags SYN,RST SYN,RST' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j INVDROP'
end

iptables_ng_rule '03 tcp flags FIN,RST FIN,RST' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j INVDROP'
end

iptables_ng_rule '03 tcp flags FIN,ACK FIN' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,ACK FIN -j INVDROP'
end

iptables_ng_rule '03 tcp flags PSH,ACK PSH' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags PSH,ACK PSH -j INVDROP'
end

iptables_ng_rule '03 tcp flags ACK,URG URG' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags ACK,URG URG -j INVDROP'
end

iptables_ng_rule '03 tcp flags not FIN,SYN,RST,ACK SYN' do
  chain 'INPUT'
  rule '-p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j INVDROP'
end
