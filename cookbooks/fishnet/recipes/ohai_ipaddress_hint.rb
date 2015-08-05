ohai 'reload_ipaddress_hint' do
  plugin ['ipaddress', 'ip6address']
  action :nothing
end

cookbook_file "#{node['ohai']['plugin_path']}/ipaddress_hint.rb" do
  source 'plugins/ipaddress_hint.rb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'ohai[reload_ipaddress_hint]', :immediately
end

# This could be simplified, but I wanted to make sure that there are no nil
# values in the generated JSON
ipaddress_data = {}
ipaddress_data['primary_nic'] = node['fishnet']['primary_nic'] if node['fishnet']['primary_nic']
ipaddress_data['public_ipv4'] = node['fishnet']['public_ipv4'] if node['fishnet']['public_ipv4']
ipaddress_data['public_ipv6'] = node['fishnet']['public_ipv6'] if node['fishnet']['public_ipv6']

ohai_hint 'ipaddress' do
  content ipaddress_data
  notifies :reload, 'ohai[reload_ipaddress_hint]', :immediately
end

include_recipe 'ohai::default'
