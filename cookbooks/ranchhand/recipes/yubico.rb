# Yubikey sudo authentication
package 'libpam-yubico' do
  action :install
end

directory "#{node['etc']['passwd'][node['ranchhand']['admin_name']]['dir']}/.yubico" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  mode '0700'
  recursive true
end

file "#{node['etc']['passwd'][node['ranchhand']['admin_name']]['dir']}/.yubico/authorized_yubikeys" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  mode '0644'
  content <<-EOYUBIKEY
#{node['ranchhand']['admin_name']}:ccccccdtvgin
EOYUBIKEY
end

node.default['pam_d']['services'] = {
  'sudo' => node['ranchhand']['pam_sudo_yubikey']
}
include_recipe 'pam'
