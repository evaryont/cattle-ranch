node.override['nginx']['package_name'] = 'nginx-extras'
include_recipe 'nginx::default'
package 'apt-transport-https'
package 'ca-certificates'

apt_repository 'passenger' do
  uri          'https://oss-binaries.phusionpassenger.com/apt/passenger'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          '561F9B9CAC40B2F7'
  deb_src      false
end

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # nginx-naxsi config
        ##
        # Uncomment it if you installed nginx-naxsi
        ##

        # include /etc/nginx/naxsi_core.rules;

file '/etc/nginx/conf.d/phusion_passenger.conf' do
  content <<-EOENV
##
# Phusion Passenger config
##

passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/bin/ruby;
EOENV
  mode '0644'
end

file '/etc/nginx/sites-available/default.dpkg-old' do
  action :delete
end
