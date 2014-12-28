#
# Cookbook Name:: ranchhand
# Recipe:: motd
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

# Only run this particular recipe on Ubuntu nodes.
if node["platform"] != "ubuntu"
  return
end

# Remove some of the cruft/advertising that Ubuntu installs by default.
file "/etc/update-motd.d/00-header" do
  action :delete
end
file "/etc/update-motd.d/10-help-text" do
  action :delete
end
file "/etc/update-motd.d/51-cloudguest" do
  action :delete
end
file "/etc/update-motd.d/50-landscape-sysinfo" do
  action :delete
  manage_symlink_source false
end

# Ensure we have landscape-common installed so sysinfo below works
package 'landscape-common'

# The system information is still useful, so show that. However, disable the
# LandscapeLink plugin as I don't use Ubuntu Landscape. (Therefore functioning
# as just an advert instead of providing any use.)
file "/etc/update-motd.d/51-sysinfo" do
  mode '0755'
  content <<EOSH
#!/bin/sh

landscape-sysinfo --exclude-sysinfo-plugins=LandscapeLink
EOSH
end

