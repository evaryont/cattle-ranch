package 'openssl headers' do
  package_name node['ranchhand']['openssl_dev']
end.run_action(:install)

chef_gem 'cheffish'
require 'cheffish'

include_recipe 'chef-vault::default'

chef_data_bag 'ssl'
