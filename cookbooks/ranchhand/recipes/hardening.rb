directory '/etc/security/limits.d' do
  owner 'root'
  group 'root'
  mode '0755'
end
include_recipe 'os-hardening::default'
