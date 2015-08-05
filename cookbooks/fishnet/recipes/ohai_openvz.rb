ohai 'reload_openvz_public' do
  plugin 'OpenvzPublic'
  action :nothing
end

cookbook_file "#{node['ohai']['plugin_path']}/openvz_public.rb" do
  source 'plugins/openvz_public.rb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'ohai[reload_openvz_public]', :immediately
end

include_recipe 'ohai::default'
