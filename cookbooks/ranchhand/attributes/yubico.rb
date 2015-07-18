if node['platform_family'] == 'debian'
  node.default['ranchand']['yubikey'] = true

  node.default['ranchhand']['pam_sudo_yubikey'] = {
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
  node.default['ranchand']['yubikey'] = false

  node.default['ranchhand']['pam_sudo_yubikey'] = {
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
