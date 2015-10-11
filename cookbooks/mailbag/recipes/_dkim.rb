node['opendkim']['packages']['tools'].each do |dkim_tool_package|
  package dkim_tool_package
end

node.override['opendkim']['conf']['Domain'] = node['ranchhand']['domain_name']
node.override['opendkim']['conf']['Keyfile'] = "#{node['mailbag']['opendkim_dir']}/#{node.name}.private"
node.override['opendkim']['conf']['Mode'] = 'sv'
node.override['opendkim']['conf']['OversignHeaders'] = 'From'
node.override['opendkim']['conf']['RequireSafeKeys'] = 'yes'
node.override['opendkim']['conf']['Selector'] = node.name
node.override['opendkim']['conf']['Socket'] = "local:#{node['mailbag']['opendkim_socket']}"
node.override['opendkim']['conf']['Syslog'] = 'yes'
node.override['opendkim']['conf']['Umask'] = '002'
node.override['opendkim']['conf']['UserID'] = "#{node['opendkim']['user']}:#{node['opendkim']['group']}"
include_recipe 'opendkim'

# This directory will store the DKIM key and example configuration
directory node['mailbag']['opendkim_dir'] do
  mode '0750'
  owner node['opendkim']['user']
  group node['opendkim']['group']
end

# Generate a 2048-bit RSA key to use for signing emails & an example DNS record
execute 'opendkim-genkey' do
  command "/usr/bin/opendkim-genkey -s #{node.name} -b 2048 -r -d #{node['ranchhand']['domain_name']} -D #{node['mailbag']['opendkim_dir']}"
  creates "#{node['mailbag']['opendkim_dir']}/#{node.name}.private"
  user  node['opendkim']['user']
  group node['opendkim']['group']
end

file "#{node['mailbag']['opendkim_dir']}/#{node.name}.private" do
  mode '0640'
  owner node['opendkim']['user']
  group node['opendkim']['group']
end
file "#{node['mailbag']['opendkim_dir']}/#{node.name}.txt" do
  mode '0644'
  owner node['opendkim']['user']
  group node['opendkim']['group']
end
