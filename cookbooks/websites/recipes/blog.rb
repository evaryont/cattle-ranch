# directory to store the HTML, etc, for my blog
directory node['websites']['blog_dir'] do
  owner node['ranchhand']['admin_name']
  group node['nginx']['group']
  mode '0755'
end

# make a symlink inside my home dir for easy access (I'm likely to forget where
# in the filesystem I put the dir)
link "#{node['etc']['passwd'][node['ranchhand']['admin_name']]['dir']}/website" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  to node['websites']['blog_dir']
end

evsme_cert = certificate_manage 'evaryont.me' do
  cert_path node['ranchhand']['ssl_cert_dir']
  owner node['nginx']['user']
  group node['nginx']['user']
  nginx_cert true
  data_bag 'ssl'
  data_bag_type 'encrypted'
end

# fill in configuration for nginx to find it
template "#{node['nginx']['dir']}/domains/evaryont.me.d/blog" do
  source 'blog.erb'
  owner  node['nginx']['user']
  group  node['nginx']['group']
  variables({'cert' => evsme_cert})
end

# turn the site on
nginx_site 'blog' do
  enable true
end
