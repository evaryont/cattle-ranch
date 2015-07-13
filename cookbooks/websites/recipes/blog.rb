# directory to store the HTML, etc, for my blog
directory node['websites']['blog_dir'] do
  owner node['ranchhand']['admin_name']
  group node['nginx']['group']
  mode '0755'
end

# make a symlink inside my home dir for easy access (I'm likely to forget where
# in the FS I put the dir)
link "#{node['etc']['passwd'][node['ranchhand']['admin_name']]['dir']}/website" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  to node['websites']['blog_dir']
end

# fill in configuration for nginx to find it
template '/etc/nginx/sites-available/blog' do
  source 'blog_nginx.erb'
  owner  node['nginx']['user']
  group  node['nginx']['group']
end

# turn the site on
nginx_site 'blog' do
  enble true
end
