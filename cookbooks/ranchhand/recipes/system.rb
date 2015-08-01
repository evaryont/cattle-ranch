system_hostname "#{node.name}.evaryont.me" do
  short_hostname node.name
  domain_name node['ranchhand']['domain_name']
  # Dummy values that are still (somewhat) useful
  static_hosts {
    '8.8.8.8' => 'dns1.google.com',
    '8.8.4.4' => 'dns2.google.com',
  }
end

system_timezone 'Etc/UTC'

if arch?
  # The system cookbook triggers cron on Arch due to the cron cookbook itself
  # not being compatible. But I don't use it, so stop chef from managing it
  begin
    unwind 'package[cronie]'
    unwind 'service[cron]'
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.debug "cronie package or cron service not found, that's 100% OK..."
    # Do nothing
  end
end
