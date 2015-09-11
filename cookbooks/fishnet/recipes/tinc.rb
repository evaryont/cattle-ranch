# Installs the Tinc VPN. Requires chef-client mode.
#
# Specifically, the pre-release version

=begin
# Generate a unique address based on the SSH RSA key. Based on 3ofcoin's method
unless node['fishnet']['tinc_hex_address']
  require 'digest/md5'
  ha_base = node['keys']['ssh']['host_rsa_public']
  loop do
    # Grab the last 2 digits of the digest to get 8 bits of information. This
    # is what Tinc will use to allocate an IP
    ha = Digest::MD5.hexdigest(ha_base)[-2..-1]

    # Append a random number to change the digest for the next go around if this
    # time doesn't work
    ha_base = "#{ha_base}#{rand(100)}"

    next if ha == '00'
    next if ha == 'ff'

    if search(:node, "fishnet_tinc_hex_address:#{ha}").empty?
      node.set['fishnet']['tinc_hex_address'] = ha
      node.save
      break
    end
  end

  Chef::Log.info "New Tinc hex address set: #{node['fishnet']['tinc_hex_address']}"
end

ipv4_addr = "#{node['fishnet']['tinc_ipv4_prefix']}.#{node['fishnet']['tinc_hex_address']}"
Chef::Log.info "Tinc VPN IP address: #{ipv4_addr}"
=end

node.override["tinc"]["ipv6_subnet"] = "fc00:c0a1:face"
node.override["tinc"]["iptables"] = false
node.override["tinc"]["net"] = "aether"
include_recipe "tinc::default"

# Make a hosts entry for each host in the tinc VPN
search(:node, 'tinc_host_file:[* TO *]').each do |peer_node|

  hostsfile_entry peer_node['tinc']['ipv6_address'] do
    hostname  "#{peer_node['tinc']['name']}.vpn"
    unique    true
  end

end

iptables_ng_rule '43-tinc-tcp' do
  chain 'INPUT'
  rule '--protocol tcp --dport 655 --match state --state NEW --jump ACCEPT'
end
iptables_ng_rule '43-tinc-udp' do
  chain 'INPUT'
  rule '--protocol udp --dport 655 --match state --state NEW --jump ACCEPT'
end
