directory '/etc/security/limits.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

include_recipe 'os-hardening::default'

if arch?
  # pam_ccreds is an AUR package, which won't be detected if it's not already
  # installed. Don't worry about the package anyways on arch.
  unwind 'package[pam-ccreds]'
end
