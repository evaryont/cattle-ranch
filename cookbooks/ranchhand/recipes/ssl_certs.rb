# set up the directory for chef-managed SSL keys, root limited. However the
# public keys are stored within, so make sure to save off (to a variable) the
# certificate resource!
dIrectory node.default['ranchhand']['ssl_cert_dir'] do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

include_recipe 'managed_directory::default'

managed_directory node.default['ranchhand']['ssl_cert_dir'] do
  clean_directories true
  clean_links true
  clean_files true
end

execute 'generate-dhparam' do
  command "openssl dhparam -out #{node['ranchhand']['ssl_cert_dir']}/dhparam.pem 2048"
  creates "#{node['ranchhand']['ssl_cert_dir']}/dhparam.pem"
end
