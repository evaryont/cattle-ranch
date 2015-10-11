node.default['mailbag']['opendkim_socket'] = '/var/run/opendkim.socket'
node.default['mailbag']['opendkim_dir'] = '/var/mail/dkim'
node.default['mailbag']['my_domains'] = %w[localhost]
node.default['mailbag']['aliases'] = {}
node.default['mailbag']['emails'] = ["boss@nogweii.xyz"]

# I don't expect this to ever change, but extracting it into a variable in case
# it ever does, for future maintenance
node.default['mailbag']['postfix_private_dir'] = '/var/spool/postfix/private'
