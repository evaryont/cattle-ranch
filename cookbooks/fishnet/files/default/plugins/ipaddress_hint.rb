# A plugin for ohai that allows the sysadmin to override the public IP for the
# node, in case the default algorithm doesn't work for them.
#
# This plugin uses ohai's hint system. Place a file in one of paths defined
# (usually /etc/chef/ohai_hints) called 'ipaddress.json' in the following
# format:
#
#     {
#       "primary_nic": "eth0",
#       "public_ipv4": "127.0.0.1",
#       "public_ipv6": "::1"
#     }
#
# Every key is optional. `primary_nic` has lesser priority, and the plugin will
# use the first IP associated with the interface specified. If you want to
# override the detected IPs, set them manually via the other keys.

Ohai.plugin(:IpaddressHint) do

  provides 'ipaddress', 'ip6address'

  depends 'ipaddress'
  depends 'network'
  depends 'network/interfaces'

  def lookup_address_by_nic(nic, net_family)
    if network['interfaces'][nic]
      network['interfaces'][nic]['addresses'].each do |ip, params|
        if params['family'] == net_family
          return [nic, ip]
        end
      end
    end
    return [nil, nil]
  end

  collect_data(:default) do
    ipv4_address, ipv6_address = nil

    ipaddress = hint? 'ipaddress' # Ohai hint

    # Lookup IP addresses based on the hinted network device
    if ipaddress['primary_nic']
      ipv4_address = lookup_address_by_nic(ipaddress['primary_nic'], 'inet')
      ipv6_address = lookup_address_by_nic(ipaddress['primary_nic'], 'inet6')
    end

    # But also let the syadmin override the detected IPs
    if ipaddress['public_ipv4']
      ipv4_address = ipaddress['public_ipv4']
    end
    if ipaddress['public_ipv6']
      ipv6_address = ipaddress['public_ipv6']
    end

    if !ipv4_address && !ipv6_address
      Ohai::Log.info('Neither public_ipv4 nor public_ipv6 are set, skipping ohai ipaddress hint.')
    else
      Ohai::Log.info("Ohai hint: override ipaddress to IPv4 #{ipv4_address} & IPv6 #{ipv6_address}.")
      ipaddress  ipv4_address if ipv4_address
      ip6address ipv6_address if ipv6_address
    end
  end
end
