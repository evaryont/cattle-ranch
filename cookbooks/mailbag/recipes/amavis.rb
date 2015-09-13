node.default['spamassassin']['conf']['required_score'] = 5
include_recipe 'onddo-spamassassin::default'

node.default["clamav"]["clamd"]["enabled"] = true
node.default["clamav"]["freshclam"]["enabled"] = true
include_recipe 'clamav::default'

package "amavisd-new"

%w(zoo unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl
   libauthen-sasl-perl clamav-docs daemon libio-string-perl
   libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl).each do |support_pkg|
  package support_pkg
end
