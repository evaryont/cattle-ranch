# Configure the server to run an imap server

node.default['dovecot']['conf_files_mode'] = '00640'

nogweii_cert = certificate_manage 'nogweii.xyz' do
  cert_path node['ranchhand']['ssl_cert_dir']
  owner node['nginx']['user']
  group node['nginx']['user']
  nginx_cert true
  data_bag 'ssl'
  data_bag_type 'encrypted'
end
node.override['dovecot']['conf']['ssl_cert'] = nogweii_cert.certificate
node.override['dovecot']['conf']['ssl_key'] = nogweii_cert.key
node.override['dovecot']['conf']['ssl'] = true

node.override['dovecot']['conf']['ssl_protocols'] = "!SSLv2 !SSLv3"
node.override['dovecot']['conf']['ssl_cipher_list'] = "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
node.override['dovecot']['conf']['ssl_prefer_server_ciphers'] = "yes"
node.override['dovecot']['conf']['ssl_dh_parameters_length'] = 2048
node.override['dovecot']['conf']['ssl_parameters_regenerate'] = 168

node.override['dovecot']['conf']['log_path'] = 'syslog'
node.override['dovecot']['conf']['syslog_facility'] = 'mail'
node.override['dovecot']['conf']['log_timestamp'] = '"%Y-%m-%d %H:%M:%S"'

node.override['dovecot']['conf']['postmaster_address'] = 'postmaster@nogweii.xyz'
node.override['dovecot']['conf']['hostname'] = 'oregano.nogweii.xyz'

node.override['dovecot']['protocols']['imap'] = {}
node.override['dovecot']['protocols']['lmtp'] = {
  'mail_plugins' => 'sieve',
  'postmaster_address' => 'postmaster@nogweii.xyz'
}
node.override['dovecot']['services']['lmtp']['listeners'] = [
  {
    'unix:/var/spool/postfix/private/dovecot-lmtp' => {
      'mode'  => '0600',
      'group' => 'postfix',
      'user'  => 'postfix'
    }
  }
]
node.override['dovecot']['services']['lmtp']['user'] = 'mail'

node.override['dovecot']['protocols']['sieve'] = {}

include_recipe 'dovecot::default'
