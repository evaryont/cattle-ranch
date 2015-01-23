# Various packages that I like installed
package 'htop'
package 'zsh'
package 'git-doc' if node['platform'] == 'ubuntu'
package 'vim-nox' if node['platform'] == 'ubuntu'

# Ensure that I, the admin/user, exist
colin_user = user 'colin' do
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

colin_dir = node['etc']['passwd']['colin']['dir']

directory colin_dir do
  owner 'colin'
  group 'colin'
  mode '0700'
  recursive true
end

# Make sure that my dotfiles are cloned
directory File.join(colin_dir,'dotfiles') do
  owner 'colin'
  group 'colin'
  recursive true
end

git File.join(colin_dir,'dotfiles') do
  repo 'https://github.com/evaryont/dotfiles.git'
  # Use the 'absolute' branch name. Bit by #2079. Wait until Chef 12 is fleshed
  # out, and shipped with Chef-DK, as it includes the fix.
  branch 'refs/heads/master'
  enable_checkout false
  user 'colin'
  group 'colin'
  enable_submodules true
  action :sync
  notifies :run, 'execute[rake dotfiles task]'
end

execute 'rake dotfiles task' do
  command 'rake dotfiles'
  cwd File.join(colin_dir,'dotfiles')
  user 'colin'
  group 'colin'
  environment "DOTFILES_HOME_DIR" => node['etc']['passwd']['colin']['dir']
  action :nothing
end

# Ensure my SSH keys are up-to-date, by using the list from Github
directory File.join(colin_dir,'.ssh') do
  owner 'colin'
  group 'colin'
  mode '0700'
  recursive true
end

remote_file 'evaryont github keys' do
  owner 'colin'
  group 'colin'
  source 'https://github.com/evaryont.keys'
  path File.join(colin_dir,'.ssh','authorized_keys')
  mode '0600'
end
