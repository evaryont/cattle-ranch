directory '/etc/security/limits.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

include_recipe 'os-hardening::packages'
include_recipe 'os-hardening::limits'
include_recipe 'os-hardening::login_defs'
include_recipe 'os-hardening::minimize_access'
include_recipe 'os-hardening::pam'
include_recipe 'os-hardening::profile'
include_recipe 'os-hardening::securetty'
include_recipe 'os-hardening::suid_sgid' if node['security']['suid_sgid']['enforce']

if arch?
  # pam_ccreds is an AUR package, which won't be detected if it's not already
  # installed. Don't worry about the package anyways on arch.
  unwind 'package[pam-ccreds]'
end
