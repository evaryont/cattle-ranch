node.default['locale']['lang'] = 'en_US.UTF-8'
node.default['locale']['lc_all'] = 'en_US.UTF-8'

file '/etc/locale.gen' do
  content <<-EOLOCALE
# #{node['config_disclaimer']}

en_US.UTF-8 UTF-8
en_US ISO-8859-1
EOLOCALE
  owner 'root'
  group 'root'
  mode '0644'
end

include_recipe 'locale::default'
