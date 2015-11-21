# create the directory with chef (as root), so git doesn't try (since the user
# it's running as doesn't have permission to in the parent directory)
directory '/var/www/passphrase_toy' do
  user node['nginx']['user']
  group node['nginx']['group']
  mode '0664'
end

# Pull source from github
git '/var/www/passphrase_toy' do
  repo 'https://github.com/evaryont/pgp_pass_phrase'
  # Use the 'absolute' branch name. Bit by #2079. Wait until Chef 12 is fleshed
  # out, and shipped with Chef-DK, as it includes the fix.
  branch 'refs/heads/master'
  enable_checkout false
  user node['nginx']['user']
  group node['nginx']['group']
  action :sync
end

# Tell nginx about it
template "#{node['nginx']['dir']}/domains/evs.sx.d/passphrase" do
  source 'passphrase.erb'
  owner  node['nginx']['user']
  group  node['nginx']['group']
  notifies :reload, 'service[nginx]', :delayed
end
