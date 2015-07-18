system_hostname "#{node.name}.evaryont.me"
system_timezone 'Etc/UTC'

if arch?
  # The system cookbook triggers cron on Arch due to the cron cookbook itself
  # not being compatible. But I don't use it, so stop chef from managing it
  unwind 'package[cronie]'
  unwind 'service[cron]'
end
