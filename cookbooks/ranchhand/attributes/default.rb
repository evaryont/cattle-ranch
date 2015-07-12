node.default['ranchhand']['is_gigabit'] = true
node.default['ranchhand']['mosh'] = false

# If the node has a 'real' IPv6 address, not just loopback
if node['ip6addresss'] && node['ip6addresss'] != '::1'
  node.default['ranchhand']['ipv6'] = true
else
  node.default['ranchhand']['ipv6'] = false
  node.override['iptables-ng']['enabled_ip_versions'] = [4]
  node.override['network']['ipv6']['enable'] = false
end

if node['platform'] == 'ubuntu'
  node.default['ranchhand']['extra_packages'] = %w(git-doc vim-nox)
  node.default['ranchhand']['sudo_yubikey'] = {
    'main' => {
      '_1' => { # The hash key name is unnecessary
        'interface' => '#%PAM-1.0' # magic comment?
      },
      '_2' => {
        'interface' => 'auth',
        'control_flag' => 'sufficient',
        'name' => 'pam_yubico.so',
        'args' => 'id=21505 secret=ZMLXN+bZRePH/goMko1NwTuHW8Y=M urllist=https://api.yubico.com/wsapi/2.0/verify',
        'disabled' => false
      }
    },
    'includes' => [
      "common-auth",
      "common-account",
      "common-session-noninteractive"
    ]
  }

elsif node['platform'] == 'arch'
  node.default['ranchhand']['extra_packages'] = %w(vim vim-runtime)

  node.default['ranchhand']['sudo_yubikey'] = {
    'main' => {
      '_1' => { # The hash key name is unnecessary
        'interface' => '#%PAM-1.0' # magic comment?
      },
      '_2' => {
        'interface' => 'auth',
        'control_flag' => 'sufficient',
        'name' => 'pam_yubico.so',
        'args' => 'id=21505 secret=ZMLXN+bZRePH/goMko1NwTuHW8Y=M urllist=https://api.yubico.com/wsapi/2.0/verify',
        'disabled' => false
      },
      '_3' => {
        'interface' => 'auth',
        'control_flag' => 'include',
        'name' => 'system-auth',
        'args' => '',
        'disabled' => false
      },
      '_4' => {
        'interface' => 'account',
        'control_flag' => 'include',
        'name' => 'system-auth',
        'args' => '',
        'disabled' => false
      },
      '_5' => {
        'interface' => 'session',
        'control_flag' => 'include',
        'name' => 'system-auth',
        'args' => '',
        'disabled' => false
      }
    },
    'includes' => [ ]
  }
end

