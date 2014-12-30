source 'https://supermarket.chef.io'

cookbook 'mysql'
cookbook 'apt'
cookbook 'git'
cookbook 'sysstat'
cookbook 'chef-client'
cookbook 'omnibus_updater', '~> 1.0.2'
cookbook 'chef_handler'
cookbook 'sudo'
cookbook 'php-fpm'
cookbook 'logrotate'
cookbook 'build-essential'
cookbook 'chef-sugar'
cookbook 'hipchat'
cookbook 'motd', git: 'https://github.com/evaryont/motd'
cookbook 'sshd'
cookbook 'brightbox-ruby', '~> 1.2.0'
cookbook 'taskwarrior'

Dir['cookbooks/*'].each do |cookbook_dir|
  cookbook File.basename(cookbook_dir), path: cookbook_dir
end
