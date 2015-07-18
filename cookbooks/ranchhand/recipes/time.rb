# Conditionally include the ntp cookbook, only when the server is not managed by
# OpenVZ (since it won't work ever)
unless node['virtualization']['system'] == 'openvz'
  include_recipe 'ntp::default'
end
