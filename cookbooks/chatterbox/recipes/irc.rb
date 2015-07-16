# This recipe sets up weechat to run as a service

package 'weechat'

# ensure we have all of the optional dependencies installed
%w(perl python2 lua tcl ruby aspell guile xmpppy).each do |optdepend|
  package optdepend
end

# Tmux will host the weechat instance, ensuring it has a virtual terminal to
# bind to, and can continue running if I ever disconnect from SSH
package 'tmux'

file '/etc/systemd/system/weechat@.service' do
  contents <<EOSERVICE
[Unit]
Description=Weechat IRC Client (in tmux) for %I
Requires=network.target local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
# don't kill the rest of tmux when this is stopped
KillMode=none
User=%I
ExecStart=/usr/bin/tmux -2 new-session -d -s irc /usr/bin/weechat
ExecStop=/usr/bin/tmux kill-session -t irc
WorkingDirectory=/home/%I/

[Install]
WantedBy=multi-user.target
EOSERVICE
  owner 'root'
  group 'root'
  mode '0644'
end

service "weechat@#{node['ranchhand']['admin_name']}" do
  action [:enable, :start]
end
