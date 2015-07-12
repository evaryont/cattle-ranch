# Package popularity contest! Contribute usage statistics back upstream to the
# packaging teams.

if debian? || ubuntu?
  include_recipe 'ranchhand::popcon_debian'
elsif arch?
  include_recipe 'ranchhand::popcon_arch'
end
