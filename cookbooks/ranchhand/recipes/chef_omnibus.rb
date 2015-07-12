# only include the automatic updater for chef for a few distros. Notably,
# omnibus_updater doesn't work at all in Arch Linux, so avoid including it
# there.
if centos? || ubuntu? || debian? || rhel?
  include_recipe 'omnibus_updater::default'
end
