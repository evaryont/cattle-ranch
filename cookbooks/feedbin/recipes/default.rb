#
# Cookbook Name:: feedbin
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

include_recipe 'git::default'
include_recipe 'brightbox-ruby::default'
node.override['postgresql']['enable_pgdg_apt'] = true
node.override['postgresql']['version'] = '9.2'
node.default['postgresql']['contrib']['extensions'] = ['hstore']
include_recipe 'postgresql::client'
include_recipe 'postgresql::ruby'
include_recipe 'postgresql::server'
include_recipe 'postgresql::config_initdb'
include_recipe 'postgresql::config_pgtune'
include_recipe 'postgresql::contrib'
include_recipe 'redisio::default'
include_recipe 'redisio::enable'

# for curb, the wrapper gem of curl
package 'libcurl4-openssl-dev'
# for rmagick, interface to ImageMagick
package 'libmagickwand-dev'
gem_package 'bundler'
gem_package 'redis'

username = 'feederino'
groupname = 'feeders'
homedir = '/opt/feedbin'

user username do
  system true
  home homedir
  supports manage_home: true
  shell '/bin/bash'
  comment 'feed reading application user'
end
group groupname do
  system true
  members [username]
end

directory homedir do
  owner username
  group groupname
  mode '0755'
end

directory "#{homedir}/feedbin" do
  owner username
  group groupname
  mode '0755'
end

git "#{homedir}/feedbin" do
  repo 'https://github.com/feedbin/feedbin.git'
  # Use the 'absolute' branch name. Bit by #2079. Wait until Chef 12 is fleshed
  # out, and shipped with Chef-DK, as it includes the fix.
  enable_checkout false
  user username
  group groupname
  enable_submodules true
  action :sync
end

directory "#{homedir}/refresher" do
  owner username
  group groupname
  mode '0755'
end

git "#{homedir}/refresher" do
  repo 'https://github.com/feedbin/refresher.git'
  enable_checkout false
  user username
  group groupname
  enable_submodules true
  action :sync
end

ruby_block 'update Gemfile to use our version of ruby' do
  block do
    file = Chef::Util::FileEdit.new("#{homedir}/feedbin/Gemfile")
    file.search_file_delete_line(/^ruby /)
    file.write_file
  end
  subscribes :run, "git[#{homedir}/feedbin]", :immediately
end

pgsql_conn_info = {
  host:     '127.0.0.1',
  port:     node['postgresql']['config']['port'],
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database 'feedbin' do
  connection pgsql_conn_info
  action :create
end

postgresql_database_user 'feedbin_db' do
  connection pgsql_conn_info
  password node['postgresql']['password']['feedbin']
  database_name 'feedbin'
  privileges [:all]
  action [:create, :grant]
end

postgres_url = URI.parse('postgres://localhost')
postgres_url.user = 'feedbin_db'
postgres_url.password = node['postgresql']['password']['feedbin']
postgres_url.host = 'localhost'
postgres_url.path = "/feedbin"

redis_url = URI.parse('redis://localhost')
redis_url.port = 6379

file "#{homedir}/feedbin/.env" do
  content <<-EOENV
export GEM_HOME=#{homedir}/feedbin/vendor/bundle
export PATH=#{homedir}/feedbin/vendor/bundle/gems/bin:${PATH}
export SECRET_KEY_BASE=#{node['feedbin']['secret_key']}
export DATABASE_URL='#{postgres_url.to_s}'
export POSTGRES_USERNAME=feedbin
export REDIS_URL='#{redis_url.to_s}'
EOENV
  mode '0600'
  owner username
  group groupname
end

directory "#{homedir}/feedbin/vendor/bundle" do
  recursive true
  mode '0755'
  owner username
  group groupname
end

execute 'bundle install --path=vendor/bundle' do
  user username
  cwd "#{homedir}/feedbin"
  action :nothing
  subscribes :run, "git[#{homedir}/feedbin]", :immediately
end

execute "bundle exec rake db:setup && touch #{homedir}/.db_setup_ran" do
  user username
  cwd "#{homedir}/feedbin"
  creates "#{homedir}/.db_setup_ran"
  action :nothing
  subscribes :run, "git[#{homedir}/feedbin]"
end
