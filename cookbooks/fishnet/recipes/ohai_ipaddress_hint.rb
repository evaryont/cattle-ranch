node.override['ohai']['plugins']['fishnet'] = 'plugins'

# This could be simplified, but I wanted to make sure that there are no nil
# values in the generated JSON
ipaddress_data = {}
ipaddress_data['primary_nic'] = node['fishnet']['primary_nic'] if node['fishnet']['primary_nic']
ipaddress_data['public_ipv4'] = node['fishnet']['public_ipv4'] if node['fishnet']['public_ipv4']
ipaddress_data['public_ipv6'] = node['fishnet']['public_ipv6'] if node['fishnet']['public_ipv6']

include_recipe 'ohai::default'

ohai_hint 'ipaddress' do
  content ipaddress_data
  notifies :reload, 'ohai[custom_plugins]', :immediately
end
