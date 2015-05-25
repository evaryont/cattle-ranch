# Configure the server to run an smtp server

node.override['postfix']['mail_type'] = 'master'
mail_server_domain = 'aether.nu'
pf_main = node.override['postfix']['main']

node.override['postfix']['master']['submission'] = true

# What network addresses should postfix trust? Answer: Only itself.
pf_main['mynetworks'] = [ "127.0.0.0/8" ]
# What domain should this mail server answer to?
pf_main['mydomain'] = mail_server_domain
# When a local/shell user sends a mail, what domain should be implied? Since
# we're an MX server, we should use the same thing as $mydomain.
pf_main['myorigin'] = mail_server_domain
# Listen on all IP interfaces. IPv6 inlcuded!
pf_main['inet_interfaces'] = "all"
# Generic smtpd banner goes here, less discoverable info the better
pf_main['smtpd_banner'] = '$myhostname ESMTP $mail_name'
# ... TODO: describe
pf_main['readme_directory'] = 'no'

# -- TLS Configuration
pf_main['smtpd_use_tls'] = 'yes'
pf_main['smtpd_tls_ciphers'] = 'high'
pf_main['smtpd_tls_exclude_ciphers'] = 'aNULL, MD5, DES, 3DES, DES-CBC3-SHA, RC4-SHA, AES256-SHA, AES128-SHA'
pf_main['smtp_tls_protocols'] = '!SSLv2, SSLv3, TLSv1'
pf_main['smtpd_tls_mandatory_protocols'] = 'TLSv1, TLSv1.1, TLSv1.2'
pf_main['smtpd_tls_mandatory_ciphers'] = 'high'
pf_main['tls_high_cipherlist'] = 'ECDH+aRSA+AES256:ECDH+aRSA+AES128:AES256-SHA:DES-CBC3-SHA'
pf_main['smtp_tls_note_starttls_offer'] = 'yes'
pf_main['smtpd_tls_received_header'] = 'yes'
pf_main['smtpd_tls_session_cache_database'] = 'btree:${queue_directory}/smtpd_scache'
pf_main['smtp_tls_session_cache_database'] = 'btree:${queue_directory}/smtp_scache'
pf_main['smtpd_tls_auth_only'] = 'yes'
pf_main['smtp_tls_security_level'] = 'may'
pf_main['smtp_tls_loglevel'] = '2'
# TODO: PKI with chef-vault
pf_main['smtpd_tls_cert_file'] = 'PATH_TO_PUBLIC_KEY'
pf_main['smtpd_tls_key_file'] = 'PATH_TO_PRIVATE_KEY'

# Require a client to send us a HELO/EHLO. Spammers often won't, legit clients
# that don't suck and pretty much don't exist any more.
pf_main['smtpd_helo_required'] = 'yes'

# Waste some of spammer's time before rejecting them. Also mitigates some amount
# of user discovery.
pf_main['smtpd_delay_reject'] = 'yes'
pf_main['disable_vrfy_command'] = 'yes'

# This a bit sneaky on my part, but it's a neat trick. Like Google's magic '+'
# in the email address, but it works for a lot of older/dumber web forms that
# think + isn't a legit character in an email address. I don't/won't use any
# dots in my personal account names, so this works pretty well.
pf_main['recipient_delimiter'] = '.'

include_recipe 'postfix::server'

chef_gem 'chef-rewind'
require 'chef/rewind'

rewind "template[#{node['postfix']['conf_dir']}/master.cf]" do
  source 'my_pf_master.cf.erb'
  cookbook 'mailbag'
end
