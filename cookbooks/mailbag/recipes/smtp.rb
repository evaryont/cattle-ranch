# Configure the server to run an smtp server

# This is a list of all of the domains this server is responsible for.
domains = Array[node['mailbag']['my_domains'] + ['localhost']].flatten.sort.uniq
standard_email_aliases = %w[webmaster postmaster hostmaster abuse admin root]

node.override['postfix']['mail_type'] = 'master'
pf_main = node.override['postfix']['main']

node.override['postfix']['master']['submission'] = true

# What network addresses should postfix trust? Answer: Only itself.
#pf_main['mynetworks'] = [ "127.0.0.0/8" ]
# What domain should this mail server answer to?
pf_main['mydomain'] = node['ranchhand']['domain_name']
# When a local/shell user sends a mail, what domain should be implied? Since
# we're an MX server, we should use the same thing as $mydomain.
pf_main['myorigin'] = node['ranchhand']['domain_name']
# What name does postfix call this server, when talking to other machines?
pf_main['myhostname'] = "#{node.name}.#{node['ranchhand']['domain_name']}"

pf_main['local_transport'] = 'virtual'
pf_main['local_recipient_maps'] = '$virtual_mailbox_maps'

# List of domains to use the virtual transport, which is every domain I care
# about
pf_main['virtual_mailbox_domains'] = domains

# Listen on all IP interfaces. IPv6 included!
pf_main['inet_interfaces'] = "all"
# Generic smtpd banner goes here, less discoverable info the better
pf_main['smtpd_banner'] = '$myhostname ESMTP $mail_name'

# Don't send new mail notifications to console users
pf_main['biff'] = 'no'
# appending .domain is the MUA's job
pf_main['append_dot_mydomain'] = 'no'

standard_email_mappings = []
# Given the list of standard email users that various industries expect, and the
# list of domains I manage, create a map for all of them across all domains to
# the virtual user boss
domains.each do |domain_part|
  standard_email_aliases.each do |user_part|
    standard_email_mappings << ["#{user_part}@#{domain_part}", "boss"]
  end
end

node.override['postfix']['virtual_alias_domains_db'] = '/etc/postfix/virtual_mailboxes'
pf_main['virtual_alias_maps'] = "#{node['postfix']['virtual_alias_db_type']}:#{node['postfix']['virtual_alias_db']}"
pf_main['virtual_mailbox_maps'] = "#{node['postfix']['virtual_alias_domains_db_type']}:#{node['postfix']['virtual_alias_domains_db']}"
pf_main['smtpd_sender_login_maps'] = pf_main['virtual_mailbox_maps']
node.override['postfix']['use_virtual_aliases_domains'] = true
node.override['postfix']['use_virtual_aliases'] = true
node.override['postfix']['virtual_aliases'] = Hash[standard_email_mappings].merge(node['mailbag']['aliases'])
node.override['postfix']['virtual_aliases_domains'] = Hash[node['mailbag']['emails'].map { |email_address| [email_address, "valid"] }]
node.override['postfix']['main']['virtual_alias_domains'] = ""

# -- TLS Configuration
nogweii_cert = certificate_manage 'nogweii.xyz' do
  cert_path node['ranchhand']['ssl_cert_dir']
  owner node['nginx']['user']
  group node['nginx']['user']
  nginx_cert true
  data_bag 'ssl'
  data_bag_type 'encrypted'
end
pf_main['smtpd_use_tls'] = 'yes'
pf_main['smtpd_tls_ciphers'] = 'medium'
pf_main['smtpd_tls_dh1024_param_file'] = "#{node['ranchhand']['ssl_cert_dir']}/dhparam.pem"
pf_main['smtpd_tls_exclude_ciphers'] = %w(aNULL MD5 DES 3DES DES-CBC3-SHA RC4-SHA AES256-SHA AES128-SHA)
pf_main['smtpd_tls_mandatory_ciphers'] = 'high'
# Disable SSL in a variety of situations
pf_main['smtpd_tls_mandatory_protocols'] = %w(!SSLv2 !SSLv3)
pf_main['smtp_tls_mandatory_protocols'] = %w(!SSLv2 !SSLv3)
pf_main['smtp_tls_protocols'] = %w(!SSLv2 !SSLv3)
pf_main['smtpd_tls_protocols'] = %w(!SSLv2 !SSLv3)
pf_main['smtpd_tls_auth_only'] = 'yes'
pf_main['tls_high_cipherlist'] = 'ECDH+aRSA+AES256:ECDH+aRSA+AES128:AES256-SHA:DES-CBC3-SHA'
pf_main['smtp_tls_note_starttls_offer'] = 'yes'
pf_main['smtpd_tls_received_header'] = 'yes'
pf_main['smtpd_tls_session_cache_database'] = 'btree:${data_directory}/smtpd_scache'
pf_main['smtp_tls_session_cache_database'] = 'btree:${data_directory}/smtp_scache'
pf_main['smtpd_tls_auth_only'] = 'yes'
pf_main['smtpd_tls_security_level'] = 'may'
pf_main['smtp_tls_security_level'] = 'dane'
pf_main['smtpd_tls_cert_file'] = nogweii_cert.certificate
pf_main['smtpd_tls_key_file'] = nogweii_cert.key
pf_main['smtp_tls_note_starttls_offer'] = 'yes'

# increase the verbosity to get a summary of TLS connections
pf_main['smtp_tls_loglevel'] = 1
pf_main['smtpd_tls_loglevel'] = 1

# Require a client to send us a HELO/EHLO. Spammers often won't, legit clients
# that suck pretty much don't exist any more.
pf_main['smtpd_helo_required'] = 'yes'

# Require the client to send a valid HELO
pf_main['smtpd_helo_restrictions'] = %w(permit_mynetworks reject_invalid_helo_hostname)

# reject incoming mail when the sender's address doesn't have a valid A or MX
# record
pf_main['smtpd_sender_restrictions'] = %w(
  reject_unknown_address
  reject_non_fqdn_sender
  reject_unknown_sender_domain
  reject_unverified_sender
)

pf_main['disable_vrfy_command'] = 'yes'
pf_main['strict_rfc821_envelopes'] = 'yes'

# A more brusque error code for clients postfix has decided to drop
pf_main['invalid_hostname_reject_code'] = 554
pf_main['multi_recipient_bounce_reject_code'] = 554
pf_main['non_fqdn_reject_code'] = 554
pf_main['relay_domains_reject_code'] = 554
pf_main['unknown_address_reject_code'] = 554
pf_main['unknown_client_reject_code'] = 554
pf_main['unknown_hostname_reject_code'] = 554
pf_main['unknown_local_recipient_reject_code'] = 554
pf_main['unknown_relay_recipient_reject_code'] = 554
pf_main['unknown_virtual_alias_reject_code'] = 554
pf_main['unknown_virtual_mailbox_reject_code'] = 554
pf_main['unverified_recipient_reject_code'] = 554
pf_main['unverified_sender_reject_code'] = 554

#pf_main['smtpd_tls_received_header'] = 'yes'

# Waste some of spammer's time before rejecting them. Also mitigates some amount
# of user discovery.
pf_main['smtpd_delay_reject'] = 'yes'
pf_main['disable_vrfy_command'] = 'yes'

pf_main['smtpd_recipient_restrictions'] = %w(
  reject_invalid_hostname
  reject_non_fqdn_hostname
  reject_non_fqdn_recipient
  reject_unknown_recipient_domain
  permit_sasl_authenticated
  permit_mynetworks
  reject_unauth_pipelining
  reject_unauth_destination
  reject_unverified_recipient
  reject_unlisted_recipient
  check_policy_service unix:private/policyd-spf
  reject
)
  #check_policy_service inet:127.0.0.1:10023 # TODO: postgrey

# Ensure the SPF policy server has enough time to do the DNS queries before
# postfix times it out
pf_main['policyd-spf_time_limit'] = 3600

# This a bit sneaky on my part, but it's a neat trick. Like Google's magic '+'
# in the email address, but it works for a lot of older/dumber web forms that
# think + isn't a legit character in an email address. I don't/won't use any
# dots in my personal account names, so this works pretty well.
pf_main['recipient_delimiter'] = '.'

# -- Postscreen configuration
postscreen_access_cidr = "#{node['postfix']['conf_dir']}/postscreen_access.cidr"
postscreen_dnsbl_reply_map = "#{node['postfix']['conf_dir']}/postscreen_dnsbl_reply_map.pcre"
pf_main['postscreen_access_list'] = ['permit_mynetworks',
                                     "cidr:#{postscreen_access_cidr}"]
pf_main['postscreen_blacklist_action'] = 'drop'
pf_main['postscreen_dnsbl_action'] = 'enforce'
pf_main['postscreen_dnsbl_reply_map'] = "pcre:#{postscreen_dnsbl_reply_map}"
pf_main['postscreen_dnsbl_sites'] = ['zen.spamhaus.org*3',
                                     'b.barracudacentral.org*2',
                                     'bl.spamcop.net',
                                     'psbl.surriel.com',
                                     'bl.mailspike.net',
                                     'swl.spamhaus.org*-4']
# TODO: 'list.dnswl.org*-4', get a dns recursive resolver setup, as google's is
# blocked
pf_main['postscreen_dnsbl_threshold'] = '3'
pf_main['postscreen_greet_action'] = 'enforce'
pf_main['postscreen_whitelist_interfaces'] = ['192.168.0.0/24',
                                              'static:all']
pf_main['postscreen_bare_newline_action'] = 'enforce'
pf_main['postscreen_bare_newline_enable'] = 'yes'
pf_main['postscreen_non_smtp_command_enable'] = 'yes'
pf_main['postscreen_pipelining_enable'] = 'yes'
pf_main['postscreen_dnsbl_action'] = 'enforce'
pf_main['postscreen_greet_action'] = 'enforce'

pf_main['virtual_transport'] = "lmtp:unix:private/dovecot-lmtp"

pf_main['milter_protocol'] = 2
# if the milters can't be reached, continue on anyways
pf_main['milter_default_action'] = 'accept'
pf_main['smtpd_milters'] = ["unix:#{node['mailbag']['opendkim_socket']}"]
pf_main['non_smtpd_milters'] = ["unix:#{node['mailbag']['opendkim_socket']}"]

pf_main['smtp_header_checks'] = "pcre:#{node['postfix']['conf_dir']}/header_checks_anonymized.pcre"

pf_main['smtpd_sasl_type'] = 'dovecot'
pf_main['smtpd_sasl_path'] = 'private/auth'
pf_main['smtpd_sasl_auth_enable'] = 'yes'
pf_main['smtpd_sasl_security_options'] = 'noanonymous'

pf_main['smtp_dns_support_level'] = 'dnssec'

include_recipe 'postfix::server'

%w(doc pcre cdb).each do |extra_postfix_pkg|
  package "postfix-#{extra_postfix_pkg}"
end

# Install supplementary programs for policy services, milters, etc.
package "postfix-policyd-spf-python"

chef_gem 'chef-rewind'
require 'chef/rewind'

# Use the master.cf template from my cookbook
rewind "template[#{node['postfix']['conf_dir']}/master.cf]" do
  source 'my_pf_master.cf.erb'
  cookbook 'mailbag'
end

file postscreen_access_cidr do
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[postfix]'
  content <<EOPOSTSCREEN_ACCESS
# A simple combined white/blacklist
# Only "permit", "reject" and "dunno" work on the RHS
# This is a CIDR table, so see cidr_table(5) for LHS syntax

# There is nothing here, for now.
EOPOSTSCREEN_ACCESS
end

file postscreen_dnsbl_reply_map do
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[postfix]'
  content <<EOPOSTSCREEN_DNSBL
# We will be rejecting much mail which is listed in multiple DNSBLs.
# We're not proud of some of the lists we are using, thus have given
# them lower scores in postscreen_dnsbl_sites listing. So this checks
# the DNSBL name postscreen(8) gets from dnsblog(8), and if it's not
# one of our Tier 1 DNSBL sites, it changes what the sender will see:
# This is a PCRE table, so see pcre_table(5) for syntax

!/^zen\.spamhaus\.org$/         multiple DNS-based blocklists
EOPOSTSCREEN_DNSBL
end

file "#{node['postfix']['conf_dir']}/header_checks_anonymized.pcre" do
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[postfix]'
  content <<EOHEADER_CHECKS
# A series of regexes to apply to outgoing mail so a few headers that can leak
# information about the user is stripped
# Remove the first line of the Received: header. Note that we cannot fully
# remove the Received: header because OpenDKIM requires that a header be present
# when signing outbound mail. The first line is where the user's home IP address
# would be.

/^\s*Received:[^\n]*(.*)/ REPLACE Received: from authenticated-user (#{pf_main['myhostname']} [#{node['ipaddress']}])$1

# Remove other typically private information.
/^\s*User-Agent:/        IGNORE
/^\s*X-Enigmail:/        IGNORE
/^\s*X-Mailer:/          IGNORE
/^\s*X-Originating-IP:/  IGNORE
/^\s*X-Pgp-Agent:/       IGNORE

# The Mime-Version header can leak the user agent too, e.g. in Mime-Version: 1.0 (Mac OS X Mail 8.1 \(2010.6\)).
/^\s*(Mime-Version:\s*[0-9\.]+)\s.+/ REPLACE $1
EOHEADER_CHECKS
end
