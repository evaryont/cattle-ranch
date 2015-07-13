# Yubikey sudo authentication
package 'libpam-yubico' do
  action :install
end

directory "#{colin_dir}/.yubico" do
  owner 'colin'
  group 'colin'
  mode '0700'
  recursive true
end

file "#{colin_dir}/.yubico/authorized_yubikeys" do
  owner 'colin'
  group 'colin'
  mode '0644'
  content <<-EOYUBIKEY
colin:ccccccdtvgin
EOYUBIKEY
end

node.default['pam_d']['services'] = {
  'sudo' => node['ranchhand']['pam_sudo_yubikey']
}
include_recipe 'pam'
