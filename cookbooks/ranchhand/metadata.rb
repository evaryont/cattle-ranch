name             'ranchhand'
maintainer       'Colin Shea'
maintainer_email 'colin@shea.at'
license          'all_rights'
description      'Helper cookbook for cattle-ranch'
long_description 'Various helper recipes for my private chef repository'
version          '0.8.39'

depends 'sshd'
depends 'iptables-ng'
depends 'sysctl'
depends 'mosh'
depends 'locale'
depends 'pam'
depends 'chef-sugar'
depends 'chef-vault'
depends 'os-hardening'
depends 'nginx'
depends 'apache2'
depends 'omnibus_updater'
depends 'apt-periodic', '~> 0.2'
depends 'ntp'
depends 'system'
depends 'managed_directory'
depends 'janitor'
depends 'certificate'

depends 'websites'
