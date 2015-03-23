# Set default policies for iptables chains
iptables_ng_chain 'input drop' do
  chain 'INPUT'
  policy 'DROP [0:0]'
end
iptables_ng_chain 'forward drop' do
  chain 'FORWARD'
  policy 'DROP [0:0]'
end
iptables_ng_chain 'output allow' do
  chain 'OUTPUT'
  policy 'ACCEPT [0:0]'
end

# drop all packets that Linux thinks are invalid. NB: Make sure that this is
# *after* the ICMPv6 Neighbor Discovery allow rule! They are always marked as
# invalid.
iptables_ng_rule '09 drop invalid packets' do
  chain 'INPUT'
  rule '-m conntrack --ctstate INVALID -j DROP'
end

# A variety of rules to drop TCP packets that can't just happen. Redundant?
iptables_ng_rule '03 tcp flags FIN,SYN,RST,PSH,ACK,URG NONE' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP'
end

iptables_ng_rule '03 tcp flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP'
end

iptables_ng_rule '03 tcp flags FIN,SYN FIN,SYN' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP'
end

iptables_ng_rule '03 tcp flags SYN,RST SYN,RST' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP'
end

iptables_ng_rule '03 tcp flags FIN,RST FIN,RST' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP'
end

iptables_ng_rule '03 tcp flags FIN,ACK FIN' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP'
end

iptables_ng_rule '03 tcp flags PSH,ACK PSH' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags PSH,ACK PSH -j DROP'
end

iptables_ng_rule '03 tcp flags ACK,URG URG' do
  chain 'INPUT'
  rule '-p tcp -m tcp --tcp-flags ACK,URG URG -j DROP'
end

iptables_ng_rule '03 tcp flags not FIN,SYN,RST,ACK SYN' do
  chain 'INPUT'
  rule '-p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j DROP'
end

# Rules inherited from Archlinux's Simple Stateful Firewall
# =========================================================

iptables_ng_rule '04 stateful allow related' do
  chain 'INPUT'
  rule '-m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT'
end

iptables_ng_rule '04 stateful allow icmpv6 neighbor discovery' do
  chain 'INPUT'
  rule '-p 41 -j ACCEPT'
  ip_version 6
end # See also, the invalid packet drop

# Find every loopback device, regardless of name, and allow all of it's traffic
node['network']['interfaces'].each do |net_if_name, net_if|
  if net_if['encapsulation'] == "Loopback"
    iptables_ng_rule "04 stateful allow loopback devise #{net_if_name}" do
      chain 'INPUT'
      rule "-i #{net_if_name} -j ACCEPT"
    end
  end
end

iptables_ng_rule '04 allow ICMPv4 ping' do
  chain 'INPUT'
  rule '-p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT'
  ip_version 4
end
iptables_ng_rule '04 allow ICMPv6 ping' do
  chain 'INPUT'
  rule '-p icmpv6 --icmpv6-type 128 -m conntrack --ctstate NEW -j ACCEPT'
  ip_version 6
end

iptables_ng_rule '04 block fake localhost' do
  chain 'INPUT'
  rule '! -i lo -d 127.0.0.0/8 -j DROP'
  ip_version 4
end
