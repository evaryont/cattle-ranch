# Installs an HTTP server. Which, depends on the settings. Defaults to nil, so
# no http server will be installed.
return unless node['ranchhand']['httpd']

# Allow HTTP & HTTPS through the firewall. HTTP is blocked if
# node[ranchhand][https_only] is set to true
http_firewall_jump = (node['ranchhand']['https_only'] ? 'DROP' : 'ACCEPT')
iptables_ng_rule '40-http' do
  chain 'INPUT'
  rule "--protocol tcp --dport 80 --match state --state NEW --jump #{http_firewall_jump}"
end
iptables_ng_rule '40-https' do
  chain 'INPUT'
  rule '--protocol tcp --dport 443 --match state --state NEW --jump ACCEPT'
end

include_recipe 'ranchhand::ssl_certs'

# Install the chosen web server. It's expected that it's only one or the other.
if node['ranchhand']['httpd'] == 'nginx'
  include_recipe 'nginx::default'

  # delete some default files that interfere with sites-available
  file '/etc/nginx/conf.d/example_ssl.conf' do
    action :delete
  end
  file '/etc/nginx/conf.d/default.conf' do
    action :delete
  end

  # don't make the default site template
  unwind "template[#{node['nginx']['dir']}/sites-available/default]"
  # and ensure it's deleted from the system
  file "#{node['nginx']['dir']}/sites-available/default" do
    action :delete
  end
elsif node['ranchhand']['httpd'] == 'apache'
  include_recipe 'apache2::default'
else
  # If we don't know what the admin meant, yell at 'em.
  Chef::Log.fatal! "Unknown type of http server. What does '#{node['ranchhand']['httpd']}' mean?!? Try nginx or apache instead."
end

include_recipe 'websites::default'
