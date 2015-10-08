node.default['spamassassin']['conf']['required_score'] = 5
include_recipe 'onddo-spamassassin::default'

node.default["clamav"]["clamd"]["enabled"] = false
node.default["clamav"]["freshclam"]["enabled"] = true
include_recipe 'clamav::default'
