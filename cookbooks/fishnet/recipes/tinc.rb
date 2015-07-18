# Installs the Tinc VPN. Requires chef-client mode.
#
# Specifically, the pre-release version

# Generate a unique address based on the SSH RSA key. Based on 3ofcoin's method
unless node['fishnet']['tinc_hex_address']
  require 'digest'
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
