# Ensure the pkgstats package is installed
package 'pkgstats' do
  action :install
  notifies :run, 'execute[manual pkgstats submission]'
end

# Once it's been installed, ensure the timer has been activated for this boot.
# (It'll be automatically started if the server is ever rebooted, but I don't
# want to have to reboot the server if pkgstats hadn't been installed yet.)
execute 'manual pkgstats submission' do
  command 'systemctl start pkgstats.timer'
  action :nothing
end
