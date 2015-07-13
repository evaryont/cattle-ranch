directory '/etc/security/limits.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

if arch?
  # include this early so that unwind can find the resource
  include_recipe 'os-hardening::pam'
  # pam_ccreds is an AUR package, which won't be detected if it's not already
  # installed.
  unwind 'package[pam_ccreds]'
end

include_recipe 'os-hardening::default'

