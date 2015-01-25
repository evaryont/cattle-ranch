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
cookbook 'locale'
cookbook 'system'
cookbook 'auditd', git: 'https://github.com/yakara-ltd/auditd', ref: '63faedd23abfd768aa0f13c698cb3e9b335836f8'
cookbook 'apt-periodic', '~> 0.2.0'

Dir['cookbooks/*'].each do |cookbook_dir|
  cookbook File.basename(cookbook_dir), path: cookbook_dir
end
