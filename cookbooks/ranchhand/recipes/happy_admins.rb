# Various packages that I like installed
package 'htop'
package 'zsh'
node['ranchhand']['extra_packages'].each do |extra_pkg_name|
  package extra_pkg_name
end

@admin_name = node['ranchhand']['admin_name']

# Ensure that I, the admin/user, exist
colin_user = user @admin_name do
  comment 'The admin of this box, Colin Shea'
  shell '/usr/bin/zsh'
  action :nothing
end

# And some magic to force Ohai to be refreshed immediately.
colin_user.run_action(:create)
ohai_resource = ohai 'colin_user_update' do
  action :nothing
end
ohai_resource.run_action(:reload) if colin_user.updated?

colin_dir = node['etc']['passwd'][@admin_name]['dir']

directory colin_dir do
  owner @admin_name
  group @admin_name
  mode '0700'
  recursive true
end

# Make sure that my dotfiles are cloned
directory File.join(colin_dir,'dotfiles') do
  owner @admin_name
  group @admin_name
  recursive true
end

git File.join(colin_dir,'dotfiles') do
  repo 'https://github.com/evaryont/dotfiles.git'
  # Use the 'absolute' branch name. Bit by #2079. Wait until Chef 12 is fleshed
  # out, and shipped with Chef-DK, as it includes the fix.
  branch 'refs/heads/master'
  enable_checkout false
  user @admin_name
  group @admin_name
  enable_submodules true
  action :sync
  notifies :run, 'execute[rake dotfiles task]'
end

execute 'rake dotfiles task' do
  command 'rake dotfiles'
  cwd File.join(colin_dir,'dotfiles')
  user @admin_name
  group @admin_name
  environment "DOTFILES_HOME_DIR" => node['etc']['passwd'][@admin_name]['dir']
  action :nothing
end

# Ensure my SSH keys are up-to-date, by using the list from Github
directory File.join(colin_dir,'.ssh') do
  owner @admin_name
  group @admin_name
  mode '0700'
  recursive true
end

remote_file 'evaryont github keys' do
  owner @admin_name
  group @admin_name
  source 'https://github.com/evaryont.keys'
  path File.join(colin_dir,'.ssh','authorized_keys')
  mode '0600'
end

if node['ranchhand']['yubikey']
  include_recipe 'ranchhand::yubico'
end
