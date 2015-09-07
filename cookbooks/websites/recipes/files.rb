# Recipe to setup & configure my file depot site. It's just a simple directory
# for me to place arbitrary files and have a public link to them. More advanced
# file management and access is left to better tools. It's all about the quick &
# dirty here.

@file_depot_dir = '/var/www/files'

# it is assumed that the directory is a git dir.
directory @file_depot_dir do
  owner node['ranchhand']['admin_name']
  group node['nginx']['group']
  mode '0755'
end

directory "#{@file_depot_dir}/.git/hooks" do
  recursive true
end

# This setting will tell git to accept incoming pushes for branches that have
# been checked out already. However it does that in such a way to prevent
# changes to on disk files...
execute 'git denyCurrentBranch' do
  command '/usr/bin/git config receive.denyCurrentBranch ignore'
  cwd @file_depot_dir
  action :nothing
end

# ...so we use this post-receive hook to force the state of HEAD to be up to
# date
file "#{@file_depot_dir}/.git/hooks/post-receive" do
  content <<EOPOST_REC
#!/bin/bash

test "${PWD%/.git}" != "$PWD" && cd ..
unset GIT_DIR GIT_WORK_TREE

git reset --hard
EOPOST_REC
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  mode '0755'
  notifies :run, 'execute[git denyCurrentBranch]'
end

link "#{node['etc']['passwd'][node['ranchhand']['admin_name']]['dir']}/files" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  to "#{@file_depot_dir}/downloads"
end

link "/etc/nginx/sites-available/files" do
  owner node['ranchhand']['admin_name']
  group node['ranchhand']['admin_name']
  to "#{@file_depot_dir}/file_depot.nginx"
end

nginx_site 'files' do
  enable true
end
