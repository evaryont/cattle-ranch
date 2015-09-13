node.default['spamassassin']['conf']['required_score'] = 5
include_recipe 'onddo-spamassassin::default'

node.default["clamav"]["clamd"]["enabled"] = true
node.default["clamav"]["freshclam"]["enabled"] = true
include_recipe 'clamav::default'

package "amavisd-new"

%w(zoo unzip arj nomarch lzop cabextract libnet-ldap-perl clamav-docs daemon
   libnet-ident-perl zip razor libdbi-perl pyzor libmail-dkim-perl).each do |support_pkg|
  package support_pkg
end
