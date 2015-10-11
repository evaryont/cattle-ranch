autoconfig_path = "/var/opt/mozilla-autoconfig-#{node['ranchhand']['domain_name']}.xml"
# fill in the thunderbird autoconfig XML
template autoconfig_path do
  source 'autoconfig.erb'
  owner  node['nginx']['user']
  group  node['nginx']['group']
  variables({domain: node['ranchhand']['domain_name'],
             email_server: search(:node, 'run_list:*mailbag*default*')[0]["fqdn"]})
end

# then tell nginx how to route it
file "#{node['nginx']['dir']}/domains/#{node['ranchhand']['domain_name']}.d/autoconfig" do
  owner  node['nginx']['user']
  group  node['nginx']['group']
  content <<-EOLOC
location = /.well-known/autoconfig/mail/config-v1.1.xml {
    alias #{autoconfig_path};
}
EOLOC
  notifies :reload, 'service[nginx]', :delayed
end
