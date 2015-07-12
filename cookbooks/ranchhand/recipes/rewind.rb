chef_gem 'chef-rewind' do
    action :nothing
end.run_action(:install)
require 'chef/rewind'
