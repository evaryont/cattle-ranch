# Popularity contest for Debian configuration

package 'popularity-contest' do
  action :install
end

require 'digest/md5'

@submission_url = "http://popcon.debian.org/cgi-bin/popcon.cgi"

file "/etc/popularity-contest.conf" do
  content <<-EOPOPCON
PARTICIPATE="yes"
MY_ID="#{Digest::MD5.hexdigest(node["keys"]["ssh"]["host_rsa_public"] || '')}"
SUBMITURLS=#@submission_url
USE_HTTP="yes"
# Needs a modern popcon client & gpg installed
ENCRYPT="maybe"
EOPOPCON
  only_if { File.exists?('/etc/cron.daily/popularity-contest') && !node["keys"]["ssh"]["host_rsa_public"].nil? }
end

# TODO: pkgstats for arch linux
