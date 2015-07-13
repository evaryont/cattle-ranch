# Depending on the distribution, install some flavor of automatic upgrades.

if debian? || ubuntu?
  include_recipe "recipe[apt-periodic::default]"
elsif arch?
  directory "/etc/systemd/system"

  file "/etc/systemd/system/pacman-sync.timer" do
    content <<-EOTIMER
[Unit]
Description=Ensure pacman has up-to-date databases

[Timer]
OnCalendar=daily
Persistent=true
 
[Install]
WantedBy=timers.target
EOTIMER
    notifies :run, 'execute[enable and start pacman-sync]'
  end

  file "/etc/systemd/system/pacman-sync.service" do
    content <<-EOSERVICE
[Unit]
Description=Sync pacman databases

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Sy
EOSERVICE
  end

  execute 'enable and start pacman-sync' do
    command 'systemctl enable pacman-sync.timer && systemctl start pacman-sync.timer'
    action :nothing
  end
end
