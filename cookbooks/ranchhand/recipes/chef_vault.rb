# Install openssl headers on the system, but only do so on detected platforms.
# (See attributes/default.rb) If there isn't a detected library to install (like
# on Arch), skip this step.
package 'openssl headers' do
  package_name node['ranchhand']['openssl_dev']
end.run_action(:install) if node['ranchhand']['openssl_dev']

# Install the cheffish gem since it's useful to manage resources related to the
# chef server itself (like data bags!)
chef_gem 'cheffish'
require 'cheffish'

# Ensure chef-vault is installed on all the nodes
include_recipe 'chef-vault::default'

# This is a data bag that will be used to store SSL certs, to be used for HTTPS,
# STARTTLS in SMTP, and others.
chef_data_bag 'ssl'
