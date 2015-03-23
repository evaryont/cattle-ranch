# Popularity contest for Ubuntu configuration

require 'digest/md5'

file "/etc/popularity-contest.conf" do
  content <<-EOPOPCON
PARTICIPATE="yes"
SUBMITURLS="https://popcon.ubuntu.com/popcon-submit.cgi"
MY_ID="#{Digest::MD5.hexdigest(node["keys"]["ssh"]["host_rsa_public"])}"
EOPOPCON
  only_if { File.exists? '/etc/cron.daily/popularity-contest' }
end

# TODO: pkgstats for arch linux
